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
        %{"meeting_id" => meeting_id, "organization_id" => organization_id} = params,
        _session,
        socket
      ) do
    organization = Organizations.get_organization!(socket.assigns.current_user, organization_id)
    meeting = Meetings.get_meeting!(organization, meeting_id)
    members = Meetings.list_uninvited_members(meeting)
    attendees = Meetings.list_attendees(meeting)

    socket
    |> assign(:organization, organization)
    |> assign(:meeting, meeting)
    |> assign(:attendees, attendees)
    |> assign(:members, members)
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, :show, _params) do
    {:noreply, socket |> assign(:page_title, "Show Meeting")}
  end

  @impl true
  def handle_event("invite_attendee", %{"id" => member_id}, socket) do
    {:ok, attendee} = Meetings.add_attendee(socket.assigns.meeting, member_id)
    IO.inspect(attendee, label: "Attendee")

    {:noreply,
     update(socket, :attendees, fn attendees ->
       [attendee | attendees]
     end)}
  end

  def handle_event("remove_attendee", %{"id" => attendee_id}, socket) do
    {1, r} = Meetings.remove_attendee(socket.assigns.meeting, attendee_id)
    IO.inspect(r, label: "Remove Attendee")

    {:noreply,
     update(socket, :attendees, fn attendees ->
       Enum.reject(attendees, &(&1.id == attendee_id))
     end)}
  end

  def handle_event(msg, _params, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end
end
