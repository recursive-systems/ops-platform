defmodule OpsPlatform.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :hashed_password, :string, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :settings, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:organization_id])
  end
end
