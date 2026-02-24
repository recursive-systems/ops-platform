defmodule OpsPlatform.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :schedule_c_line, :string
      add :description, :text
      add :tax_deductible, :boolean, default: false, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:categories, [:organization_id])
  end
end
