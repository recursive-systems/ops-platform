defmodule OpsPlatform.Accounts.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "audit_logs" do
    field :action, :string
    field :resource_type, :string
    field :resource_id, :string
    field :changes, :map, default: %{}

    belongs_to :user, OpsPlatform.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [:action, :resource_type, :resource_id, :changes, :user_id])
    |> validate_required([:action, :resource_type])
  end
end
