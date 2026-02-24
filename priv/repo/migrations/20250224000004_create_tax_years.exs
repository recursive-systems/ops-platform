defmodule OpsPlatform.Repo.Migrations.CreateTaxYears do
  use Ecto.Migration

  def change do
    create table(:tax_years) do
      add :year, :integer, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :status, :string, null: false, default: "open"
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tax_years, [:organization_id])
    create unique_index(:tax_years, [:year, :organization_id])
  end
end
