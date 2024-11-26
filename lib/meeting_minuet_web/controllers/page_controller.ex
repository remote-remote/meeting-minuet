defmodule MeetingMinuetWeb.PageController do
  use MeetingMinuetWeb, :controller

  @registration_enabled Application.compile_env(:meeting_minuet, :registration_enabled)

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    render(assign(conn, :registration_enabled, @registration_enabled), :home, layout: false)
  end
end
