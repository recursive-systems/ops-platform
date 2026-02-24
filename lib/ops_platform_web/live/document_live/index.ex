defmodule OpsPlatformWeb.DocumentLive.Index do
  use OpsPlatformWeb, :live_view

  alias OpsPlatform.Finance

  @impl true
  def mount(_params, _session, socket) do
    org_id = socket.assigns.current_user.organization_id
    documents = Finance.list_documents(org_id)

    {:ok,
     assign(socket,
       page_title: "Documents",
       documents: documents
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Finance.get_document!(id)
    {:ok, _} = Finance.delete_document(document)

    org_id = socket.assigns.current_user.organization_id
    documents = Finance.list_documents(org_id)

    {:noreply,
     socket
     |> assign(documents: documents)
     |> put_flash(:info, "Document deleted.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-3xl font-bold">Documents</h1>
      </div>

      <div :if={@documents == []} class="card bg-base-100 shadow">
        <div class="card-body text-center text-base-content/60">
          <p>No documents uploaded yet.</p>
        </div>
      </div>

      <div :if={@documents != []} class="overflow-x-auto">
        <table class="table bg-base-100">
          <thead>
            <tr>
              <th>Title</th>
              <th>Type</th>
              <th>Category</th>
              <th>Uploaded</th>
              <th>Drive</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={doc <- @documents} class="hover">
              <td class="font-medium">{doc.title}</td>
              <td>{doc.file_type || "—"}</td>
              <td>{doc.category || "—"}</td>
              <td>
                {if doc.uploaded_at, do: Calendar.strftime(doc.uploaded_at, "%b %d, %Y"), else: "—"}
              </td>
              <td>
                <span :if={doc.google_drive_id} class="badge badge-success badge-sm">Synced</span>
                <span :if={!doc.google_drive_id} class="badge badge-ghost badge-sm">Local</span>
              </td>
              <td>
                <button
                  phx-click="delete"
                  phx-value-id={doc.id}
                  data-confirm="Delete this document?"
                  class="btn btn-ghost btn-xs text-error"
                >
                  <.icon name="hero-trash" class="size-4" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
