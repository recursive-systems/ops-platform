defmodule OpsPlatform.Finance do
  @moduledoc """
  The Finance context. Manages all financial data including accounts,
  transactions, categories, tax years, documents, and tasks.
  """

  import Ecto.Query
  alias OpsPlatform.Repo

  alias OpsPlatform.Finance.{
    Account,
    Category,
    Document,
    TaxDocument,
    TaxTask,
    TaxYear,
    Transaction
  }

  # Accounts

  def list_accounts(organization_id) do
    Account
    |> where([a], a.organization_id == ^organization_id)
    |> order_by(:name)
    |> Repo.all()
  end

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_by_external_id(external_id), do: Repo.get_by(Account, external_id: external_id)

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  # Transactions

  def list_transactions(opts \\ []) do
    Transaction
    |> join(:left, [t], a in assoc(t, :account))
    |> join(:left, [t, _a], c in assoc(t, :category))
    |> maybe_filter_by_account(opts[:account_id])
    |> maybe_filter_by_category(opts[:category_id])
    |> maybe_filter_by_kind(opts[:kind])
    |> maybe_filter_by_status(opts[:status])
    |> maybe_filter_by_date_range(opts[:start_date], opts[:end_date])
    |> maybe_search(opts[:search])
    |> order_by([t], desc: t.date)
    |> preload([:account, :category])
    |> Repo.all()
  end

  def get_transaction!(id) do
    Transaction
    |> Repo.get!(id)
    |> Repo.preload([:account, :category])
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  def upsert_transaction(attrs) do
    case attrs[:external_id] || attrs["external_id"] do
      nil ->
        create_transaction(attrs)

      external_id ->
        case Repo.get_by(Transaction, external_id: external_id) do
          nil -> create_transaction(attrs)
          existing -> update_transaction(existing, attrs)
        end
    end
  end

  defp maybe_filter_by_account(query, nil), do: query
  defp maybe_filter_by_account(query, id), do: where(query, [t], t.account_id == ^id)

  defp maybe_filter_by_category(query, nil), do: query
  defp maybe_filter_by_category(query, id), do: where(query, [t], t.category_id == ^id)

  defp maybe_filter_by_kind(query, nil), do: query
  defp maybe_filter_by_kind(query, kind), do: where(query, [t], t.kind == ^kind)

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status), do: where(query, [t], t.status == ^status)

  defp maybe_filter_by_date_range(query, nil, nil), do: query

  defp maybe_filter_by_date_range(query, start_date, nil),
    do: where(query, [t], t.date >= ^start_date)

  defp maybe_filter_by_date_range(query, nil, end_date),
    do: where(query, [t], t.date <= ^end_date)

  defp maybe_filter_by_date_range(query, start_date, end_date),
    do: where(query, [t], t.date >= ^start_date and t.date <= ^end_date)

  defp maybe_search(query, nil), do: query
  defp maybe_search(query, ""), do: query

  defp maybe_search(query, search) do
    search_term = "%#{search}%"

    where(
      query,
      [t],
      ilike(t.description, ^search_term) or ilike(t.counterparty, ^search_term)
    )
  end

  # Transaction Stats

  def transaction_stats(organization_id) do
    accounts = list_accounts(organization_id)
    account_ids = Enum.map(accounts, & &1.id)

    total_income =
      Transaction
      |> where([t], t.account_id in ^account_ids and t.kind == "income")
      |> select([t], coalesce(sum(t.amount), 0))
      |> Repo.one()

    total_expenses =
      Transaction
      |> where([t], t.account_id in ^account_ids and t.kind == "expense")
      |> select([t], coalesce(sum(t.amount), 0))
      |> Repo.one()

    pending_count =
      Transaction
      |> where([t], t.account_id in ^account_ids and t.status == "pending")
      |> Repo.aggregate(:count)

    %{
      total_income: total_income,
      total_expenses: total_expenses,
      net: Decimal.sub(total_income, total_expenses),
      pending_count: pending_count
    }
  end

  # Categories

  def list_categories(organization_id) do
    Category
    |> where([c], c.organization_id == ^organization_id)
    |> order_by(:name)
    |> Repo.all()
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  # Tax Years

  def list_tax_years(organization_id) do
    TaxYear
    |> where([ty], ty.organization_id == ^organization_id)
    |> order_by(desc: :year)
    |> Repo.all()
  end

  def get_tax_year!(id) do
    TaxYear
    |> Repo.get!(id)
    |> Repo.preload([:tax_tasks, :tax_documents])
  end

  def create_tax_year(attrs \\ %{}) do
    %TaxYear{}
    |> TaxYear.changeset(attrs)
    |> Repo.insert()
  end

  def update_tax_year(%TaxYear{} = tax_year, attrs) do
    tax_year
    |> TaxYear.changeset(attrs)
    |> Repo.update()
  end

  def delete_tax_year(%TaxYear{} = tax_year) do
    Repo.delete(tax_year)
  end

  # Tax Tasks

  def list_tax_tasks(tax_year_id) do
    TaxTask
    |> where([tt], tt.tax_year_id == ^tax_year_id)
    |> order_by(:due_date)
    |> Repo.all()
  end

  def get_tax_task!(id), do: Repo.get!(TaxTask, id)

  def create_tax_task(attrs \\ %{}) do
    %TaxTask{}
    |> TaxTask.changeset(attrs)
    |> Repo.insert()
  end

  def update_tax_task(%TaxTask{} = tax_task, attrs) do
    tax_task
    |> TaxTask.changeset(attrs)
    |> Repo.update()
  end

  def delete_tax_task(%TaxTask{} = tax_task) do
    Repo.delete(tax_task)
  end

  # Documents

  def list_documents(organization_id) do
    Document
    |> where([d], d.organization_id == ^organization_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_document!(id), do: Repo.get!(Document, id)

  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  # Tax Documents

  def list_tax_documents(tax_year_id) do
    TaxDocument
    |> where([td], td.tax_year_id == ^tax_year_id)
    |> order_by(desc: :received_at)
    |> preload(:document)
    |> Repo.all()
  end

  def get_tax_document!(id) do
    TaxDocument
    |> Repo.get!(id)
    |> Repo.preload(:document)
  end

  def create_tax_document(attrs \\ %{}) do
    %TaxDocument{}
    |> TaxDocument.changeset(attrs)
    |> Repo.insert()
  end

  def update_tax_document(%TaxDocument{} = tax_document, attrs) do
    tax_document
    |> TaxDocument.changeset(attrs)
    |> Repo.update()
  end

  def delete_tax_document(%TaxDocument{} = tax_document) do
    Repo.delete(tax_document)
  end
end
