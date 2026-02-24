defmodule OpsPlatformWeb.TaxYearLive.Show do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Finance

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tax_year = Finance.get_tax_year!(id)
    tasks = Finance.list_tax_tasks(tax_year.id)
    tax_documents = Finance.list_tax_documents(tax_year.id)

    {:ok,
     assign(socket,
       page_title: "Tax Year #{tax_year.year}",
       tax_year: tax_year,
       tasks: tasks,
       tax_documents: tax_documents,
       show_task_form: false,
       editing_task: nil
     )}
  end

  @impl true
  def handle_event("toggle_task", %{"id" => id}, socket) do
    task = Finance.get_tax_task!(id)

    new_status =
      case task.status do
        "pending" -> "completed"
        "completed" -> "pending"
        other -> other
      end

    {:ok, _} = Finance.update_tax_task(task, %{status: new_status})
    tasks = Finance.list_tax_tasks(socket.assigns.tax_year.id)
    {:noreply, assign(socket, tasks: tasks)}
  end

  @impl true
  def handle_event("new_task", _params, socket) do
    {:noreply, assign(socket, show_task_form: true, editing_task: nil)}
  end

  @impl true
  def handle_event("save_task", %{"tax_task" => params}, socket) do
    params = Map.put(params, "tax_year_id", socket.assigns.tax_year.id)

    result =
      case socket.assigns.editing_task do
        nil -> Finance.create_tax_task(params)
        task -> Finance.update_tax_task(task, params)
      end

    case result do
      {:ok, _} ->
        tasks = Finance.list_tax_tasks(socket.assigns.tax_year.id)

        {:noreply,
         socket
         |> assign(tasks: tasks, show_task_form: false, editing_task: nil)
         |> put_flash(:info, "Task saved.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not save task.")}
    end
  end

  @impl true
  def handle_event("close_task_form", _params, socket) do
    {:noreply, assign(socket, show_task_form: false, editing_task: nil)}
  end

  @impl true
  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Finance.get_tax_task!(id)
    {:ok, _} = Finance.delete_tax_task(task)
    tasks = Finance.list_tax_tasks(socket.assigns.tax_year.id)
    {:noreply, assign(socket, tasks: tasks) |> put_flash(:info, "Task deleted.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold">Tax Year {@tax_year.year}</h1>
          <p class="text-base-content/60">
            {Calendar.strftime(@tax_year.start_date, "%b %d, %Y")} — {Calendar.strftime(
              @tax_year.end_date,
              "%b %d, %Y"
            )}
          </p>
        </div>
        <div class={"badge badge-lg #{status_class(@tax_year.status)}"}>
          {@tax_year.status}
        </div>
      </div>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h2 class="card-title">Tasks</h2>
            <button phx-click="new_task" class="btn btn-primary btn-sm">
              <.icon name="hero-plus" class="size-4" /> Add Task
            </button>
          </div>

          <.modal :if={@show_task_form} id="task-modal" show on_cancel={JS.push("close_task_form")}>
            <h3 class="text-lg font-bold mb-4">
              {if @editing_task, do: "Edit Task", else: "New Task"}
            </h3>
            <form phx-submit="save_task" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Title</span></label>
                <input type="text" name="tax_task[title]" class="input input-bordered" required />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Description</span></label>
                <textarea name="tax_task[description]" class="textarea textarea-bordered"></textarea>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label"><span class="label-text">Due Date</span></label>
                  <input type="date" name="tax_task[due_date]" class="input input-bordered" />
                </div>
                <div class="form-control">
                  <label class="label"><span class="label-text">Priority</span></label>
                  <select name="tax_task[priority]" class="select select-bordered">
                    <option value="low">Low</option>
                    <option value="medium" selected>Medium</option>
                    <option value="high">High</option>
                  </select>
                </div>
              </div>
              <div class="flex justify-end">
                <button type="submit" class="btn btn-primary">Save</button>
              </div>
            </form>
          </.modal>

          <div :if={@tasks == []} class="text-base-content/60 py-4 text-center">
            No tasks yet.
          </div>

          <div
            :for={task <- @tasks}
            class="flex items-center justify-between py-3 border-b border-base-200 last:border-0"
          >
            <div class="flex items-center gap-3">
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={task.status == "completed"}
                phx-click="toggle_task"
                phx-value-id={task.id}
              />
              <div>
                <p class={"font-medium #{if task.status == "completed", do: "line-through text-base-content/40"}"}>
                  {task.title}
                </p>
                <p :if={task.due_date} class="text-sm text-base-content/60">
                  Due: {Calendar.strftime(task.due_date, "%b %d, %Y")}
                </p>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span class={"badge badge-sm #{priority_class(task.priority)}"}>{task.priority}</span>
              <button
                phx-click="delete_task"
                phx-value-id={task.id}
                data-confirm="Delete this task?"
                class="btn btn-ghost btn-xs text-error"
              >
                <.icon name="hero-trash" class="size-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h2 class="card-title">Tax Documents</h2>
          <div :if={@tax_documents == []} class="text-base-content/60 py-4 text-center">
            No tax documents received yet.
          </div>
          <div class="overflow-x-auto">
            <table :if={@tax_documents != []} class="table table-sm">
              <thead>
                <tr>
                  <th>Type</th>
                  <th>Issuer</th>
                  <th>Amount</th>
                  <th>Received</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={td <- @tax_documents}>
                  <td class="font-medium">{td.document_type}</td>
                  <td>{td.issuer || "—"}</td>
                  <td>{if td.amount, do: "$#{Decimal.round(td.amount, 2)}", else: "—"}</td>
                  <td>
                    {if td.received_at, do: Calendar.strftime(td.received_at, "%b %d, %Y"), else: "—"}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_class("open"), do: "badge-info"
  defp status_class("closed"), do: "badge-warning"
  defp status_class("filed"), do: "badge-success"
  defp status_class(_), do: "badge-ghost"

  defp priority_class("high"), do: "badge-error"
  defp priority_class("medium"), do: "badge-warning"
  defp priority_class("low"), do: "badge-info"
  defp priority_class(_), do: "badge-ghost"
end
