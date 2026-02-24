defmodule OpsPlatformWeb.FinanceLive.Index do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Finance

  @impl true
  def mount(_params, _session, socket) do
    org_id = socket.assigns.current_user.organization_id
    accounts = Finance.list_accounts(org_id)
    categories = Finance.list_categories(org_id)
    stats = Finance.transaction_stats(org_id)

    {:ok,
     assign(socket,
       page_title: "Finance",
       accounts: accounts,
       categories: categories,
       stats: stats
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-3xl font-bold">Finance Overview</h1>
        <div class="flex gap-2">
          <.link navigate={~p"/transactions"} class="btn btn-primary btn-sm">
            <.icon name="hero-banknotes" class="size-4" /> Transactions
          </.link>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Income</div>
          <div class="stat-value text-success text-2xl">${format_decimal(@stats.total_income)}</div>
        </div>
        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Expenses</div>
          <div class="stat-value text-error text-2xl">${format_decimal(@stats.total_expenses)}</div>
        </div>
        <div class="stat bg-base-100 rounded-box shadow">
          <div class="stat-title">Net</div>
          <div class="stat-value text-2xl">${format_decimal(@stats.net)}</div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Accounts ({length(@accounts)})</h2>
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Last Sync</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={account <- @accounts}>
                    <td class="font-medium">{account.name}</td>
                    <td class="capitalize">{account.type}</td>
                    <td>
                      {if account.last_sync_at,
                        do: Calendar.strftime(account.last_sync_at, "%b %d"),
                        else: "Never"}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Categories ({length(@categories)})</h2>
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Schedule C</th>
                    <th>Deductible</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={cat <- @categories}>
                    <td class="font-medium">{cat.name}</td>
                    <td>{cat.schedule_c_line || "—"}</td>
                    <td>
                      <span :if={cat.tax_deductible} class="badge badge-success badge-sm">Yes</span>
                      <span :if={!cat.tax_deductible} class="badge badge-ghost badge-sm">No</span>
                    </td>
                  </tr>
                </tbody>
              </table>
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
end
