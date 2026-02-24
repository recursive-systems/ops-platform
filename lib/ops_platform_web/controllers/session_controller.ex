defmodule OpsPlatformWeb.SessionController do
  use OpsPlatformWeb, :controller

  def create(conn, %{"email" => email, "password" => password}) do
    case OpsPlatform.Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> redirect(to: "/dashboard")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/login")
  end
end
