defmodule OpsPlatform.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :external_id, :string
      add :last_sync_at, :utc_datetime
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:organization_id])
    create unique_index(:accounts, [:external_id])
  end
end
