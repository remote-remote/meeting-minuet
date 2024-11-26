defmodule MeetingMinuetWeb.MeetingLive.Live do
  alias MeetingMinuetWeb.DTO.Member
  use MeetingMinuetWeb, :live_view

  import MeetingMinuetWeb.LayoutComponents
  alias MeetingMinuet.Meetings
  alias MeetingMinuet.Meetings.{Presence, Notifications}
  alias MeetingMinuet.Organizations

  @impl true
  def mount(%{"meeting_id" => meeting_id}, _session, socket) do
    if connected?(socket) do
      Notifications.subscribe(meeting_id)
      connect_presence(socket, meeting_id)
    end

    socket =
      socket
      |> assign(:presences, Presence.list_users(meeting_id))

    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"meeting_id" => meeting_id, "organization_id" => organization_id} = _params,
        _session,
        socket
      ) do
    organization = Organizations.get_organization!(socket.assigns.current_user, organization_id)
    meeting = Meetings.get_meeting!(organization, meeting_id)
    attendees = Meetings.list_attendees(meeting)

    {:noreply,
     socket
     |> assign(:organization, organization)
     |> assign(:meeting, meeting)
     |> assign(:attendees, attendees)}
  end

  @impl true
  def handle_event("end", _params, socket) do
    case Meetings.end_meeting(socket.assigns.meeting) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, message} ->
        {:noreply, socket |> put_flash(:error, message)}
    end
  end

  def handle_event(msg, _params, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:added_attendee, attendee}, socket) do
    {:noreply,
     socket
     |> update(:attendees, fn attendees -> attendees ++ [attendee] end)
     |> update(:uninvited_members, fn members ->
       Enum.reject(members, &(&1.id == attendee.membership_id))
     end)}
  end

  def handle_info({:removed_attendee, attendee}, socket) do
    member =
      Organizations.get_member!(attendee.membership_id)
      |> Member.map_preloaded_membership()

    {:noreply,
     socket
     |> update(:uninvited_members, fn members -> members ++ [member] end)
     |> update(:attendees, fn attendees ->
       Enum.reject(attendees, &(&1.membership_id == member.id))
     end)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff},
        socket
      ) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def handle_info({:meeting_started, meeting}, socket) do
    {:noreply, socket |> assign(:meeting, meeting)}
  end

  def handle_info({:meeting_ended, meeting}, socket) do
    {:noreply, socket |> assign(:meeting, meeting)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  defp connect_presence(socket, meeting_id) do
    if connected?(socket) do
      Presence.subscribe(meeting_id)

      %{current_user: current_user} = socket.assigns

      {:ok, _} =
        Presence.track_user(current_user, meeting_id, %{
          user_id: current_user.id
        })
    end

    socket
  end
end
