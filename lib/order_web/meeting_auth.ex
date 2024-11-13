defmodule OrderWeb.MeetingAuth do
  use OrderWeb, :verified_routes
  import Plug.Conn
  alias Order.Meetings

  def fetch_attendee(
        %{
          assigns: %{current_membership: current_membership},
          params: %{"meeting_id" => meeting_id}
        } = conn,
        _opts
      ) do
    attendee = Meetings.get_attendee(meeting_id, current_membership.id)

    if attendee do
      assign(conn, :current_attendee, attendee)
    else
      conn
    end
  end

  def mount_attendee(socket, %{"meeting_id" => meeting_id}) do
    Phoenix.Component.assign_new(socket, :current_attendee, fn ->
      Meetings.get_attendee(meeting_id, socket.assigns.current_membership.id)
    end)
  end

  def on_mount(:mount_attendee, params, _session, socket) do
    {:cont, mount_attendee(socket, params)}
  end

  def on_mount(:ensure_attendee, %{"organization_id" => org_id} = params, _session, socket) do
    socket = mount_attendee(socket, params)

    if socket.assigns.current_membership do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You do not have access to this meeting.")
        |> Phoenix.LiveView.redirect(to: ~p"/organizations/#{org_id}")

      {:halt, socket}
    end

    {:cont, socket}
  end
end
