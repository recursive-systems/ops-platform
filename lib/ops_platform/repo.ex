defmodule OpsPlatform.Repo do
  use Ecto.Repo,
    otp_app: :ops_platform,
    adapter: Ecto.Adapters.Postgres
end
