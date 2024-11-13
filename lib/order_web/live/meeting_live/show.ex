defmodule OrderWeb.MeetingLive.Show do
  use OrderWeb, :live_view

  alias Order.Meetings
  alias Order.Organizations
  import OrderWeb.LayoutComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"meeting_id" => meeting_id, "organization_id" => organization_id},
        _session,
        socket
      ) do
    organization = Organizations.get_organization!(socket.assigns.current_user, organization_id)
    meeting = Meetings.get_meeting!(organization, meeting_id)
    {:noreply, assign(socket, meeting: meeting, organization: organization, attendees: [])}
  end
end
