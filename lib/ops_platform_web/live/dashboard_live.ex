defmodule OpsPlatformWeb.DashboardLive do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Finance

  @impl true
  def mount(_params, _session, socket) do
    org_id = socket.assigns.current_user.organization_id
    stats = Finance.transaction_stats(org_id)
    tax_years = Finance.list_tax_years(org_id)
    accounts = Finance.list_accounts(org_id)

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       stats: stats,
       tax_years: tax_years,
       accounts: accounts
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-3xl font-bold">Dashboard</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Total Income</div>
          <div class="stat-value text-success">${format_decimal(@stats.total_income)}</div>
        </div>

        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Total Expenses</div>
          <div class="stat-value text-error">${format_decimal(@stats.total_expenses)}</div>
        </div>

        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Net</div>
          <div class="stat-value">${format_decimal(@stats.net)}</div>
        </div>

        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Pending Review</div>
          <div class="stat-value text-warning">{@stats.pending_count}</div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Accounts</h2>
            <div :if={@accounts == []} class="text-base-content/60">
              No accounts synced yet.
            </div>
            <div
              :for={account <- @accounts}
              class="flex justify-between items-center py-2 border-b border-base-200 last:border-0"
            >
              <div>
                <p class="font-medium">{account.name}</p>
                <p class="text-sm text-base-content/60 capitalize">{account.type}</p>
              </div>
              <div :if={account.last_sync_at} class="text-sm text-base-content/60">
                Synced: {Calendar.strftime(account.last_sync_at, "%b %d, %Y")}
              </div>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Tax Years</h2>
            <div :if={@tax_years == []} class="text-base-content/60">
              No tax years configured yet.
            </div>
            <div
              :for={ty <- @tax_years}
              class="flex justify-between items-center py-2 border-b border-base-200 last:border-0"
            >
              <div>
                <.link navigate={~p"/tax-years/#{ty.id}"} class="font-medium link link-hover">
                  {ty.year}
                </.link>
              </div>
              <div class={"badge #{status_badge_class(ty.status)}"}>
                {ty.status}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_decimal(decimal) do
    decimal
    |> Decimal.round(2)
    |> Decimal.to_string()
  end

  defp status_badge_class("open"), do: "badge-info"
  defp status_badge_class("closed"), do: "badge-warning"
  defp status_badge_class("filed"), do: "badge-success"
  defp status_badge_class(_), do: "badge-ghost"
end
