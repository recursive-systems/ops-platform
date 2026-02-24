defmodule OpsPlatform.Finance.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :external_id, :string
    field :date, :date
    field :amount, :decimal
    field :description, :string
    field :counterparty, :string
    field :kind, :string, default: "expense"
    field :status, :string, default: "pending"
    field :metadata, :map, default: %{}
    field :receipt_id, :string

    belongs_to :account, OpsPlatform.Finance.Account
    belongs_to :category, OpsPlatform.Finance.Category

    timestamps(type: :utc_datetime)
  end

  @valid_kinds ~w(income expense transfer)
  @valid_statuses ~w(pending reviewed categorized)

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :external_id,
      :date,
      :amount,
      :description,
      :counterparty,
      :kind,
      :status,
      :metadata,
      :receipt_id,
      :account_id,
      :category_id
    ])
    |> validate_required([:date, :amount, :account_id])
    |> validate_inclusion(:kind, @valid_kinds)
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint(:external_id)
  end
end
