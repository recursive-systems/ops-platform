defmodule OpsPlatformWeb.LoginLive do
  use OpsPlatformWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"email" => "", "password" => ""}))}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-base-200">
      <div class="card w-full max-w-md bg-base-100 shadow-xl">
        <div class="card-body">
          <h2 class="card-title text-2xl font-bold justify-center mb-4">Sign In</h2>
          <p class="text-center text-base-content/60 mb-6">Recursive Systems Operations Platform</p>

          <.form for={@form} action={~p"/login"} method="post" class="space-y-4">
            <div class="form-control">
              <label class="label" for="email">
                <span class="label-text">Email</span>
              </label>
              <input
                type="email"
                name="email"
                id="email"
                value={@form[:email].value}
                class="input input-bordered w-full"
                placeholder="you@example.com"
                required
              />
            </div>

            <div class="form-control">
              <label class="label" for="password">
                <span class="label-text">Password</span>
              </label>
              <input
                type="password"
                name="password"
                id="password"
                class="input input-bordered w-full"
                placeholder="••••••••"
                required
              />
            </div>

            <div class="form-control mt-6">
              <button type="submit" class="btn btn-primary w-full">
                Sign In
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
