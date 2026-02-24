defmodule OpsPlatformWeb.TransactionLive.FormComponent do
  use OpsPlatformWeb, :live_component

  alias OpsPlatform.Finance
  alias OpsPlatform.Finance.Transaction

  @impl true
  def update(assigns, socket) do
    transaction = assigns.transaction || %Transaction{}

    changeset =
      Finance.change_transaction(transaction, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       form: to_form(changeset)
     )}
  end

  @impl true
  def handle_event("validate", %{"transaction" => params}, socket) do
    transaction = socket.assigns.transaction || %Transaction{}

    changeset =
      transaction
      |> Transaction.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"transaction" => params}, socket) do
    save_transaction(socket, socket.assigns.transaction, params)
  end

  defp save_transaction(socket, nil, params) do
    case Finance.create_transaction(params) do
      {:ok, transaction} ->
        send(self(), {:transaction_saved, transaction})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, transaction, params) do
    case Finance.update_transaction(transaction, params) do
      {:ok, transaction} ->
        send(self(), {:transaction_saved, transaction})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3 class="text-lg font-bold mb-4">
        {if @transaction, do: "Edit Transaction", else: "New Transaction"}
      </h3>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <div class="form-control">
          <label class="label"><span class="label-text">Date</span></label>
          <input
            type="date"
            name="transaction[date]"
            value={@form[:date].value}
            class="input input-bordered"
            required
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Amount</span></label>
          <input
            type="number"
            step="0.01"
            name="transaction[amount]"
            value={@form[:amount].value}
            class="input input-bordered"
            required
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Description</span></label>
          <input
            type="text"
            name="transaction[description]"
            value={@form[:description].value}
            class="input input-bordered"
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Counterparty</span></label>
          <input
            type="text"
            name="transaction[counterparty]"
            value={@form[:counterparty].value}
            class="input input-bordered"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">Type</span></label>
            <select name="transaction[kind]" class="select select-bordered">
              <option value="expense" selected={to_string(@form[:kind].value) == "expense"}>
                Expense
              </option>
              <option value="income" selected={to_string(@form[:kind].value) == "income"}>
                Income
              </option>
              <option value="transfer" selected={to_string(@form[:kind].value) == "transfer"}>
                Transfer
              </option>
            </select>
          </div>

          <div class="form-control">
            <label class="label"><span class="label-text">Status</span></label>
            <select name="transaction[status]" class="select select-bordered">
              <option value="pending" selected={to_string(@form[:status].value) == "pending"}>
                Pending
              </option>
              <option value="reviewed" selected={to_string(@form[:status].value) == "reviewed"}>
                Reviewed
              </option>
              <option value="categorized" selected={to_string(@form[:status].value) == "categorized"}>
                Categorized
              </option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">Account</span></label>
            <select name="transaction[account_id]" class="select select-bordered" required>
              <option value="">Select account</option>
              <option
                :for={a <- @accounts}
                value={a.id}
                selected={to_string(@form[:account_id].value) == to_string(a.id)}
              >
                {a.name}
              </option>
            </select>
          </div>

          <div class="form-control">
            <label class="label"><span class="label-text">Category</span></label>
            <select name="transaction[category_id]" class="select select-bordered">
              <option value="">No category</option>
              <option
                :for={c <- @categories}
                value={c.id}
                selected={to_string(@form[:category_id].value) == to_string(c.id)}
              >
                {c.name}
              </option>
            </select>
          </div>
        </div>

        <div class="flex justify-end gap-2 mt-6">
          <button type="submit" class="btn btn-primary">Save</button>
        </div>
      </.form>
    </div>
    """
  end
end
