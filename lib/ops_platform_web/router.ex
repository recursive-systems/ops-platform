defmodule OpsPlatformWeb.Router do
  use OpsPlatformWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OpsPlatformWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug OpsPlatformWeb.Plugs.FetchCurrentUser
  end

  pipeline :require_auth do
    plug OpsPlatformWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", OpsPlatformWeb do
    pipe_through :browser

    live "/login", LoginLive
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Authenticated routes
  scope "/", OpsPlatformWeb do
    pipe_through [:browser, :require_auth]

    live_session :authenticated,
      on_mount: {OpsPlatformWeb.Plugs.Auth, :ensure_authenticated} do
      live "/", DashboardLive
      live "/dashboard", DashboardLive
      live "/finance", FinanceLive.Index
      live "/transactions", TransactionLive.Index
      live "/tax-years/:id", TaxYearLive.Show
      live "/documents", DocumentLive.Index
      live "/settings", SettingsLive.Index
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:ops_platform, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OpsPlatformWeb.Telemetry
    end
  end
end
