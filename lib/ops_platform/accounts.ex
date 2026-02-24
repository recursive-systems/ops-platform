defmodule OpsPlatform.Accounts do
  @moduledoc """
  The Accounts context. Manages users, organizations, and audit logging.
  """

  import Ecto.Query
  alias OpsPlatform.Accounts.{AuditLog, Organization, User}
  alias OpsPlatform.Repo

  # Organizations

  def list_organizations do
    Repo.all(Organization)
  end

  def get_organization!(id), do: Repo.get!(Organization, id)

  def get_organization_by_slug(slug), do: Repo.get_by(Organization, slug: slug)

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  # Users

  def list_users(organization_id) do
    User
    |> where([u], u.organization_id == ^organization_id)
    |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end

  # Audit Logs

  def list_audit_logs(opts \\ []) do
    AuditLog
    |> order_by(desc: :inserted_at)
    |> maybe_filter_by_user(opts[:user_id])
    |> maybe_filter_by_resource(opts[:resource_type])
    |> Repo.all()
  end

  def create_audit_log(attrs \\ %{}) do
    %AuditLog{}
    |> AuditLog.changeset(attrs)
    |> Repo.insert()
  end

  def log_action(user_id, action, resource_type, resource_id \\ nil, changes \\ %{}) do
    create_audit_log(%{
      user_id: user_id,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id && to_string(resource_id),
      changes: changes
    })
  end

  defp maybe_filter_by_user(query, nil), do: query
  defp maybe_filter_by_user(query, user_id), do: where(query, [a], a.user_id == ^user_id)

  defp maybe_filter_by_resource(query, nil), do: query
  defp maybe_filter_by_resource(query, type), do: where(query, [a], a.resource_type == ^type)
end
