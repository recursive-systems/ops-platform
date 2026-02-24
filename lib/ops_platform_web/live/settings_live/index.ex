defmodule OpsPlatformWeb.SettingsLive.Index do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    org = Accounts.get_organization!(user.organization_id)

    {:ok,
     assign(socket,
       page_title: "Settings",
       organization: org,
       user_form: to_form(Accounts.User.changeset(user, %{}), as: "user"),
       org_form: to_form(Accounts.Organization.changeset(org, %{}), as: "organization")
     )}
  end

  @impl true
  def handle_event("update_user", %{"user" => params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user)
         |> assign(user_form: to_form(Accounts.User.changeset(user, %{}), as: "user"))
         |> put_flash(:info, "Profile updated.")}

      {:error, changeset} ->
        {:noreply, assign(socket, user_form: to_form(changeset, as: "user"))}
    end
  end

  @impl true
  def handle_event("update_org", %{"organization" => params}, socket) do
    case Accounts.update_organization(socket.assigns.organization, params) do
      {:ok, org} ->
        {:noreply,
         socket
         |> assign(organization: org)
         |> assign(
           org_form: to_form(Accounts.Organization.changeset(org, %{}), as: "organization")
         )
         |> put_flash(:info, "Organization updated.")}

      {:error, changeset} ->
        {:noreply, assign(socket, org_form: to_form(changeset, as: "organization"))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-3xl font-bold">Settings</h1>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h2 class="card-title">Profile</h2>
          <.form for={@user_form} phx-submit="update_user" class="space-y-4 max-w-md">
            <div class="form-control">
              <label class="label"><span class="label-text">Name</span></label>
              <input
                type="text"
                name="user[name]"
                value={@user_form[:name].value}
                class="input input-bordered"
              />
            </div>
            <div class="form-control">
              <label class="label"><span class="label-text">Email</span></label>
              <input
                type="email"
                name="user[email]"
                value={@user_form[:email].value}
                class="input input-bordered"
              />
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Save Profile</button>
          </.form>
        </div>
      </div>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h2 class="card-title">Organization</h2>
          <.form for={@org_form} phx-submit="update_org" class="space-y-4 max-w-md">
            <div class="form-control">
              <label class="label"><span class="label-text">Name</span></label>
              <input
                type="text"
                name="organization[name]"
                value={@org_form[:name].value}
                class="input input-bordered"
              />
            </div>
            <div class="form-control">
              <label class="label"><span class="label-text">Slug</span></label>
              <input
                type="text"
                name="organization[slug]"
                value={@org_form[:slug].value}
                class="input input-bordered"
              />
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Save Organization</button>
          </.form>
        </div>
      </div>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h2 class="card-title">Integrations</h2>
          <div class="space-y-2">
            <div class="flex items-center justify-between p-3 bg-base-200 rounded-lg">
              <div>
                <p class="font-medium">Mercury Bank</p>
                <p class="text-sm text-base-content/60">Sync accounts and transactions</p>
              </div>
              <div class="badge badge-ghost">Configure in env</div>
            </div>
            <div class="flex items-center justify-between p-3 bg-base-200 rounded-lg">
              <div>
                <p class="font-medium">Google Drive</p>
                <p class="text-sm text-base-content/60">Upload and manage documents</p>
              </div>
              <div class="badge badge-ghost">Configure in env</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
