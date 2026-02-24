defmodule OpsPlatformWeb.Plugs.Auth do
  @moduledoc """
  Authentication plug that requires a logged-in user.
  Redirects to /login if unauthenticated.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session["user_id"] do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}

      user_id ->
        user = OpsPlatform.Accounts.get_user!(user_id)
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    end
  rescue
    Ecto.NoResultsError ->
      {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
  end
end
