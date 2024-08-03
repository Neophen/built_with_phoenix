defmodule BuiltWithPhoenixWeb.Router do
  use BuiltWithPhoenixWeb, :router
  use AshAuthentication.Phoenix.Router

  alias BuiltWithPhoenixWeb.Hooks.LiveUserAuth

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

    ash_authentication_live_session :public,
      on_mount: {LiveUserAuth, :live_user_optional} do
      live "/", HomeLive
      live "/suggest", SuggestLive
      live "/organizations/:id", ShowOrganizationLive
      live "/suggest-technology", SuggestTechnologyLive
    end

    # add these lines -->
    # Leave out `register_path` and `reset_path` if you don't want to support
    # user registration and/or password resets respectively.
    sign_in_route(
      # register_path: "/register",
      # reset_path: "/reset",
      on_mount: [{LiveUserAuth, :live_no_user}]
    )

    sign_out_route AuthController
    auth_routes_for BuiltWithPhoenix.Accounts.Resource.User, to: AuthController
    reset_route []
    # <-- add these lines

    ash_authentication_live_session :admin,
      on_mount: {LiveUserAuth, :live_user_required} do
      live "/admin/technologies", Admin.TechnologyLive.Index, :index
      live "/admin/technologies/new", Admin.TechnologyLive.Index, :new
      live "/admin/technologies/:id/edit", Admin.TechnologyLive.Index, :edit

      live "/admin/technologies/:id", Admin.TechnologyLive.Show, :show
      live "/admin/technologies/:id/show/edit", Admin.TechnologyLive.Show, :edit

      live "/admin/organizations", Admin.OrganizationLive.Index, :index
      live "/admin/organizations/new", Admin.OrganizationLive.Index, :new
      live "/admin/organizations/:id/edit", Admin.OrganizationLive.Index, :edit

      live "/admin/organizations/:id", Admin.OrganizationLive.Show, :show
      live "/admin/organizations/:id/show/edit", Admin.OrganizationLive.Show, :edit
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
