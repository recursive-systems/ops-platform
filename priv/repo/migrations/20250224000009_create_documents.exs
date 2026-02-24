defmodule OpsPlatform.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string, null: false
      add :file_type, :string
      add :google_drive_id, :string
      add :category, :string
      add :uploaded_at, :utc_datetime
      add :transaction_id, references(:transactions, on_delete: :nilify_all)
      add :tax_year_id, references(:tax_years, on_delete: :nilify_all)
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:organization_id])
    create index(:documents, [:transaction_id])
    create index(:documents, [:tax_year_id])
  end
end
