defmodule MeetingMinuetWeb.Router do
  use MeetingMinuetWeb, :router

  import MeetingMinuetWeb.UserAuth
  import MeetingMinuetWeb.OrgMemberAuth
  import MeetingMinuetWeb.MeetingAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MeetingMinuetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MeetingMinuetWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  scope "/", MeetingMinuetWeb do
    pipe_through [:browser, :require_authenticated_user]

    # This creates a live session. The routes in this block can be live routed
    live_session :organization_lobby,
      on_mount: {
        MeetingMinuetWeb.UserAuth,
        :ensure_authenticated
      } do
      live "/organizations", OrganizationLive.Index, :index
      live "/organizations/new", OrganizationLive.Index, :new
      live "/organizations/:organization_id/edit", OrganizationLive.Index, :edit
    end

    scope "/organizations/:organization_id" do
      pipe_through [:fetch_membership]

      live_session :organization_dashboard,
        on_mount: [
          {
            MeetingMinuetWeb.UserAuth,
            :ensure_authenticated
          },
          {
            MeetingMinuetWeb.OrgMemberAuth,
            :ensure_membership
          }
        ] do
        live "/show/edit", OrganizationLive.Show, :edit
        live "/", OrganizationLive.Show, :show
        live "/positions/new", OrganizationLive.Show, :new_position
        # TODO - implement
        live "/positions/:position_id", PositionLive.Show, :show
        live "/positions/:position_id/edit", PositionLive.Show, :edit
        live "/positions/:position_id/tenures/new", PositionLive.Show, :new_tenure
        live "/positions/:position_id/tenures/:tenure_id/edit", PositionLive.Show, :edit_tenure
        live "/meetings/new", OrganizationLive.Show, :new_meeting
        live "/members/invite", OrganizationLive.Show, :invite_member
      end

      scope "/meetings/:meeting_id" do
        pipe_through [:fetch_attendee]

        live_session :meeting,
          on_mount: [
            {
              MeetingMinuetWeb.UserAuth,
              :ensure_authenticated
            },
            {
              MeetingMinuetWeb.OrgMemberAuth,
              :ensure_membership
            },
            {
              MeetingMinuetWeb.MeetingAuth,
              :mount_attendee
            }
          ] do
          live "/", MeetingLive.Show, :show
          live "/edit", MeetingLive.Show, :edit
          live "/agenda_items/new", MeetingLive.Show, :new_agenda_item
          live "/agenda_items/:agenda_item_id", MeetingLive.Show, :edit_agenda_item
          live "/live", MeetingLive.Live, :live
        end
      end
    end
  end

  # just an experiment
  scope "/nested", MeetingMinuetWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :nested_test,
      on_mount: {
        MeetingMinuetWeb.UserAuth,
        :ensure_authenticated
      } do
      live "/:id", NestedLive.Parent
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MeetingMinuetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:meeting_minuet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MeetingMinuetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MeetingMinuetWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MeetingMinuetWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      if Application.compile_env(:meeting_minuet, :registration_enabled) do
        live "/users/register", UserRegistrationLive, :new
      end

      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", MeetingMinuetWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MeetingMinuetWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", MeetingMinuetWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{MeetingMinuetWeb.UserAuth, :mount_current_user}] do
      live "/users/accept_invitation/:token", UserInvitationLive, :edit
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
