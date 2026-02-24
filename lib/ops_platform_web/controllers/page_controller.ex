defmodule OpsPlatformWeb.PageController do
  use OpsPlatformWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
