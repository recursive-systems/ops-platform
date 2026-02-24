defmodule OpsPlatformWeb.TransactionLive.Index do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Finance

  @impl true
  def mount(_params, _session, socket) do
    org_id = socket.assigns.current_user.organization_id
    categories = Finance.list_categories(org_id)
    accounts = Finance.list_accounts(org_id)

    {:ok,
     assign(socket,
       page_title: "Transactions",
       categories: categories,
       accounts: accounts,
       filter_account: nil,
       filter_category: nil,
       filter_kind: nil,
       filter_status: nil,
       search: nil,
       show_form: false,
       editing_transaction: nil
     )
     |> load_transactions()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(
       filter_account: params["account"],
       filter_category: params["category"],
       filter_kind: params["kind"],
       filter_status: params["status"],
       search: params["search"]
     )
     |> load_transactions()}
  end

  @impl true
  def handle_event("filter", params, socket) do
    {:noreply,
     socket
     |> assign(
       filter_account: blank_to_nil(params["account_id"]),
       filter_category: blank_to_nil(params["category_id"]),
       filter_kind: blank_to_nil(params["kind"]),
       filter_status: blank_to_nil(params["status"]),
       search: blank_to_nil(params["search"])
     )
     |> load_transactions()}
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, assign(socket, show_form: true, editing_transaction: nil)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    transaction = Finance.get_transaction!(id)
    {:noreply, assign(socket, show_form: true, editing_transaction: transaction)}
  end

  @impl true
  def handle_event("close_form", _params, socket) do
    {:noreply, assign(socket, show_form: false, editing_transaction: nil)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finance.get_transaction!(id)
    {:ok, _} = Finance.delete_transaction(transaction)

    {:noreply,
     socket
     |> put_flash(:info, "Transaction deleted.")
     |> load_transactions()}
  end

  @impl true
  def handle_info({:transaction_saved, _transaction}, socket) do
    {:noreply,
     socket
     |> assign(show_form: false, editing_transaction: nil)
     |> put_flash(:info, "Transaction saved.")
     |> load_transactions()}
  end

  defp load_transactions(socket) do
    opts =
      [
        account_id: socket.assigns.filter_account,
        category_id: socket.assigns.filter_category,
        kind: socket.assigns.filter_kind,
        status: socket.assigns.filter_status,
        search: socket.assigns.search
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    transactions = Finance.list_transactions(opts)
    assign(socket, transactions: transactions)
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(val), do: val

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex justify-between items-center">
        <h1 class="text-3xl font-bold">Transactions</h1>
        <button phx-click="new" class="btn btn-primary btn-sm">
          <.icon name="hero-plus" class="size-4" /> Add Transaction
        </button>
      </div>

      <div class="card bg-base-100 shadow p-4">
        <form phx-change="filter" class="grid grid-cols-1 md:grid-cols-5 gap-3">
          <input
            type="text"
            name="search"
            value={@search}
            placeholder="Search..."
            class="input input-bordered input-sm"
            phx-debounce="300"
          />
          <select name="account_id" class="select select-bordered select-sm">
            <option value="">All Accounts</option>
            <option :for={a <- @accounts} value={a.id} selected={to_string(a.id) == @filter_account}>
              {a.name}
            </option>
          </select>
          <select name="category_id" class="select select-bordered select-sm">
            <option value="">All Categories</option>
            <option
              :for={c <- @categories}
              value={c.id}
              selected={to_string(c.id) == @filter_category}
            >
              {c.name}
            </option>
          </select>
          <select name="kind" class="select select-bordered select-sm">
            <option value="">All Types</option>
            <option value="income" selected={@filter_kind == "income"}>Income</option>
            <option value="expense" selected={@filter_kind == "expense"}>Expense</option>
            <option value="transfer" selected={@filter_kind == "transfer"}>Transfer</option>
          </select>
          <select name="status" class="select select-bordered select-sm">
            <option value="">All Statuses</option>
            <option value="pending" selected={@filter_status == "pending"}>Pending</option>
            <option value="reviewed" selected={@filter_status == "reviewed"}>Reviewed</option>
            <option value="categorized" selected={@filter_status == "categorized"}>
              Categorized
            </option>
          </select>
        </form>
      </div>

      <.modal :if={@show_form} id="transaction-modal" show on_cancel={JS.push("close_form")}>
        <.live_component
          module={OpsPlatformWeb.TransactionLive.FormComponent}
          id={(@editing_transaction && @editing_transaction.id) || :new}
          transaction={@editing_transaction}
          accounts={@accounts}
          categories={@categories}
        />
      </.modal>

      <div class="overflow-x-auto">
        <table class="table table-sm bg-base-100">
          <thead>
            <tr>
              <th>Date</th>
              <th>Description</th>
              <th>Counterparty</th>
              <th>Amount</th>
              <th>Type</th>
              <th>Category</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={txn <- @transactions} class="hover">
              <td>{txn.date}</td>
              <td class="max-w-xs truncate">{txn.description}</td>
              <td>{txn.counterparty}</td>
              <td class={if txn.kind == "income", do: "text-success", else: "text-error"}>
                ${Decimal.round(txn.amount, 2)}
              </td>
              <td><span class="badge badge-sm badge-outline capitalize">{txn.kind}</span></td>
              <td>{(txn.category && txn.category.name) || "—"}</td>
              <td>
                <span class={"badge badge-sm #{transaction_status_class(txn.status)}"}>
                  {txn.status}
                </span>
              </td>
              <td class="flex gap-1">
                <button phx-click="edit" phx-value-id={txn.id} class="btn btn-ghost btn-xs">
                  <.icon name="hero-pencil-square" class="size-4" />
                </button>
                <button
                  phx-click="delete"
                  phx-value-id={txn.id}
                  data-confirm="Are you sure?"
                  class="btn btn-ghost btn-xs text-error"
                >
                  <.icon name="hero-trash" class="size-4" />
                </button>
              </td>
            </tr>
            <tr :if={@transactions == []}>
              <td colspan="8" class="text-center text-base-content/60 py-8">
                No transactions found.
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp transaction_status_class("pending"), do: "badge-warning"
  defp transaction_status_class("reviewed"), do: "badge-info"
  defp transaction_status_class("categorized"), do: "badge-success"
  defp transaction_status_class(_), do: "badge-ghost"
end
