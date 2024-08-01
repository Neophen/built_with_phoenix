defmodule BuiltWithPhoenixWeb.Router do
  use BuiltWithPhoenixWeb, :router
  use AshAuthentication.Phoenix.Router

  alias BuiltWithPhoenix.Hooks.LiveUserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BuiltWithPhoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", BuiltWithPhoenixWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/suggest", SuggestLive
    live "/organizations/:id", ShowOrganizationLive

    # add these lines -->
    # Leave out `register_path` and `reset_path` if you don't want to support
    # user registration and/or password resets respectively.
    sign_in_route(
      register_path: "/register",
      reset_path: "/reset",
      on_mount: [{LiveUserAuth, :live_no_user}]
    )

    sign_out_route AuthController
    auth_routes_for BuiltWithPhoenix.Accounts.Resource.User, to: AuthController
    reset_route []
    # <-- add these lines

    ash_authentication_live_session :authentication_required,
      on_mount: {LiveUserAuth, :live_user_required} do
      live "/admin/technologies", TechnologyLive.Index, :index
      live "/admin/technologies/new", TechnologyLive.Index, :new
      live "/admin/technologies/:id/edit", TechnologyLive.Index, :edit

      live "/admin/technologies/:id", TechnologyLive.Show, :show
      live "/admin/technologies/:id/show/edit", TechnologyLive.Show, :edit

      live "/admin/organizations", OrganizationLive.Index, :index
      live "/admin/organizations/new", OrganizationLive.Index, :new
      live "/admin/organizations/:id/edit", OrganizationLive.Index, :edit

      live "/admin/organizations/:id", OrganizationLive.Show, :show
      live "/admin/organizations/:id/show/edit", OrganizationLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", BuiltWithPhoenixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:built_with_phoenix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BuiltWithPhoenixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
