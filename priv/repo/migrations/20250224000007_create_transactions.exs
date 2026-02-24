defmodule OpsPlatform.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :external_id, :string
      add :date, :date, null: false
      add :amount, :decimal, null: false
      add :description, :string
      add :counterparty, :string
      add :kind, :string, null: false, default: "expense"
      add :status, :string, null: false, default: "pending"
      add :metadata, :map, default: %{}
      add :receipt_id, :string
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:account_id])
    create index(:transactions, [:category_id])
    create index(:transactions, [:date])
    create unique_index(:transactions, [:external_id])
  end
end
