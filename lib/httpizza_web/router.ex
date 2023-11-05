defmodule HTTPizzaWeb.Router do
  use HTTPizzaWeb, :router

  import HTTPizzaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HTTPizzaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :stripe do
    plug HTTPizzaWeb.Plugs.Stripe
  end

  scope "/webhooks", HTTPizzaWeb do
    scope "/stripe" do
      pipe_through :stripe
      post "/", StripeController, :create
    end
  end

  scope "/", HTTPizzaWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", HTTPizzaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:httpizza, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HTTPizzaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HTTPizzaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HTTPizzaWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HTTPizzaWeb do
    pipe_through [:browser]

    live "/dashboard/:organization/team/join/:token", JoinTeamLive, :edit
  end

  scope "/", HTTPizzaWeb do
    pipe_through [:browser, :require_authenticated_admin]

    live_session :require_authenticated_admin,
      on_mount: [{HTTPizzaWeb.UserAuth, :ensure_authenticated_admin}] do
      scope "/admin" do
        live "/", AdminLive, :index
      end
    end
  end

  scope "/", HTTPizzaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HTTPizzaWeb.UserAuth, :ensure_authenticated}] do
      scope "/dashboard" do
        live "/", DashboardLive, :index

        scope "/:organization" do
          live "/", DashboardLive, :show
          live "/billing", BillingLive, :show
          live "/settings", OrganizationLive, :show
          live "/checkout", CheckoutLive, :show

          scope "/team" do
            live "/", TeamLive, :index
            live "/invite", InviteToTeamLive, :new
          end

          scope "/http-observers" do
            live "/new", NewHTTPObserverLive, :new

            scope "/:id" do
              live "/edit", EditHTTPObserverLive, :edit
            end
          end

          scope "/http-listeners" do
            live "/", HTTPListenersLive, :index
            live "/new", NewHTTPListenerLive, :index
          end

          scope "/http-observations" do
            live "/:id", HTTPObservationLive, :show
          end
        end
      end

      live "/organizations/new", NewOrganizationLive, :new
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", HTTPizzaWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HTTPizzaWeb.UserAuth, :mount_current_user}] do
      live "/", LandingLive, :index
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
