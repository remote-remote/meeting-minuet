defmodule MeetingMinuetWeb.PageController do
  use MeetingMinuetWeb, :controller

  @is_dev Application.compile_env(:meeting_minuet, :dev_routes)

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    render(assign(conn, :is_dev, @is_dev), :home, layout: false)
  end
end
