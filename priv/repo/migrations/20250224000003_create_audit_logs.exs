defmodule OpsPlatform.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :action, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :string
      add :changes, :map, default: %{}
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:audit_logs, [:user_id])
    create index(:audit_logs, [:resource_type, :resource_id])
  end
end
