defmodule OpsPlatformWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use OpsPlatformWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders your app layout with sidebar navigation.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :current_user, :map, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div :if={@current_user} class="drawer lg:drawer-open">
      <input id="sidebar-drawer" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">
        <header class="navbar bg-base-100 border-b border-base-200 lg:hidden">
          <div class="flex-none">
            <label for="sidebar-drawer" class="btn btn-square btn-ghost">
              <.icon name="hero-bars-3" class="size-5" />
            </label>
          </div>
          <div class="flex-1">
            <span class="text-lg font-semibold">Ops Platform</span>
          </div>
          <div class="flex-none">
            <.theme_toggle />
          </div>
        </header>

        <main class="flex-1 p-4 sm:p-6 lg:p-8">
          <div class="max-w-7xl mx-auto">
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>

      <div class="drawer-side z-40">
        <label for="sidebar-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
        <aside class="bg-base-200 min-h-full w-64 p-4 flex flex-col">
          <div class="mb-8">
            <a href="/" class="flex items-center gap-2 px-2">
              <img src={~p"/images/logo.svg"} width="32" />
              <span class="text-lg font-bold">Ops Platform</span>
            </a>
          </div>

          <nav class="flex-1 space-y-1">
            <.nav_link href={~p"/dashboard"} icon="hero-home">Dashboard</.nav_link>
            <.nav_link href={~p"/finance"} icon="hero-chart-bar">Finance</.nav_link>
            <.nav_link href={~p"/transactions"} icon="hero-banknotes">Transactions</.nav_link>
            <.nav_link href={~p"/documents"} icon="hero-document-text">Documents</.nav_link>
            <.nav_link href={~p"/settings"} icon="hero-cog-6-tooth">Settings</.nav_link>
          </nav>

          <div class="pt-4 border-t border-base-300 space-y-3">
            <div class="flex justify-center">
              <.theme_toggle />
            </div>
            <div class="flex items-center gap-2 px-2">
              <div class="avatar placeholder">
                <div class="bg-neutral text-neutral-content rounded-full w-8">
                  <span class="text-xs">{initials(@current_user)}</span>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium truncate">{@current_user.name}</p>
                <p class="text-xs text-base-content/60 truncate">{@current_user.email}</p>
              </div>
            </div>
            <.link
              href={~p"/logout"}
              method="delete"
              class="btn btn-ghost btn-sm w-full justify-start"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Sign Out
            </.link>
          </div>
        </aside>
      </div>
    </div>

    <div :if={!@current_user}>
      {render_slot(@inner_block)}
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :href, :string, required: true
  attr :icon, :string, required: true
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-300 transition-colors text-base-content/80 hover:text-base-content"
    >
      <.icon name={@icon} class="size-5" />
      <span class="text-sm font-medium">{render_slot(@inner_block)}</span>
    </a>
    """
  end

  defp initials(nil), do: "?"

  defp initials(user) do
    user.name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
