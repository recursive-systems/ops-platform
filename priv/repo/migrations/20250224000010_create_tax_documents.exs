defmodule OpsPlatform.Repo.Migrations.CreateTaxDocuments do
  use Ecto.Migration

  def change do
    create table(:tax_documents) do
      add :document_type, :string, null: false
      add :issuer, :string
      add :amount, :decimal
      add :received_at, :date
      add :notes, :text
      add :tax_year_id, references(:tax_years, on_delete: :delete_all), null: false
      add :document_id, references(:documents, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tax_documents, [:tax_year_id])
    create index(:tax_documents, [:document_id])
  end
end
