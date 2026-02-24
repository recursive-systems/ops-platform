defmodule OpsPlatform.Repo.Migrations.CreateTaxTasks do
  use Ecto.Migration

  def change do
    create table(:tax_tasks) do
      add :title, :string, null: false
      add :description, :text
      add :due_date, :date
      add :status, :string, null: false, default: "pending"
      add :category, :string
      add :priority, :string, null: false, default: "medium"
      add :notes, :text
      add :tax_year_id, references(:tax_years, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tax_tasks, [:tax_year_id])
  end
end
