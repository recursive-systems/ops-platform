defmodule OpsPlatformWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Plug that fetches the current user from session and assigns it to conn.
  Does not redirect - simply sets current_user to nil if not logged in.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = OpsPlatform.Accounts.get_user!(user_id)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  rescue
    Ecto.NoResultsError ->
      conn
      |> clear_session()
      |> assign(:current_user, nil)
  end
end
