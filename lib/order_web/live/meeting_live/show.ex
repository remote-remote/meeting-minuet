defmodule OrderWeb.MeetingLive.Show do
  use OrderWeb, :live_view

  alias Order.Meetings
  alias Order.Meetings.{Presence, Notifications}
  alias Order.Organizations
  import OrderWeb.LayoutComponents

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
    |> assign(:attendees, attendees)
    |> assign(:uninvited_members, uninvited_members)
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, :show, _params) do
    {:noreply, socket |> assign(:page_title, "Show Meeting")}
  end

  @impl true
  def handle_event("invite", %{"id" => membership_id}, socket) do
    {:ok, _} =
      Meetings.add_attendee(socket.assigns.meeting, String.to_integer(membership_id))

    {:noreply, socket}
  end

  def handle_event("uninvite", %{"id" => membership_id}, socket) do
    {:ok, _} = Meetings.remove_attendee(socket.assigns.meeting, membership_id)
    {:noreply, socket}
  end

  def handle_event("start", _params, socket) do
    case Meetings.start_meeting(socket.assigns.meeting) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, message} ->
        {:noreply, socket |> put_flash(:error, message)}
    end
  end

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
     |> update(:uninvited_members, fn members -> Enum.reject(members, &(&1.id == attendee.id)) end)}
  end

  def handle_info({:removed_attendee, attendee}, socket) do
    member =
      Organizations.get_member!(
        socket.assigns.organization,
        attendee.id
      )

    {:noreply,
     socket
     |> update(:uninvited_members, fn members -> members ++ [member] end)
     |> update(:attendees, fn attendees -> Enum.reject(attendees, &(&1.id == member.id)) end)}
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
