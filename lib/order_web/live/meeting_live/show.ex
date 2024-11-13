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
    attendees = Meetings.list_attendees(meeting)
    attending_member_ids = attendees |> Enum.map(& &1.id)

    uninvited_members =
      Organizations.list_members(organization)
      |> Enum.reject(fn m -> m.id in attending_member_ids end)

    socket
    |> assign(:organization, organization)
    |> assign(:meeting, meeting)
    |> stream(:attendees, attendees)
    |> stream(:uninvited_members, uninvited_members)
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, :show, _params) do
    {:noreply, socket |> assign(:page_title, "Show Meeting")}
  end

  @impl true
  def handle_event("invite", %{"id" => membership_id}, socket) do
    {:ok, attendee} =
      Meetings.add_attendee(socket.assigns.meeting, String.to_integer(membership_id))

    {:noreply,
     socket
     |> stream_insert(:attendees, attendee)
     |> stream_delete(:uninvited_members, attendee)}
  end

  def handle_event("uninvite", %{"id" => membership_id}, socket) do
    # TODO: return the member from remove_attendee
    {1, _} = Meetings.remove_attendee(socket.assigns.meeting, membership_id)

    member =
      Organizations.get_member!(
        socket.assigns.organization,
        String.to_integer(membership_id)
      )

    {:noreply,
     socket
     |> stream_insert(:uninvited_members, member)
     |> stream_delete_by_dom_id(:attendees, "attendees-#{membership_id}")}
  end

  def handle_event(msg, _params, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end
end
