defmodule MeetingMinuetWeb.MeetingLive.Show do
  alias MeetingMinuet.Meetings.AgendaItem
  alias MeetingMinuetWeb.DTO.Member
  use MeetingMinuetWeb, :live_view

  import MeetingMinuetWeb.LayoutComponents
  import MeetingMinuet.Meetings.Permissions
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
        %{"meeting_id" => meeting_id, "organization_id" => organization_id} = params,
        _session,
        socket
      ) do
    organization = Organizations.get_organization!(socket.assigns.current_user, organization_id)
    meeting = Meetings.get_meeting!(organization, meeting_id)
    attendees = Meetings.list_attendees(meeting)
    agenda_items = Meetings.list_agenda_items(meeting.id)
    attending_member_ids = attendees |> Enum.map(& &1.membership_id)

    uninvited_members =
      Organizations.list_members(organization_id)
      |> Member.map_list()
      |> Enum.reject(fn m -> m.id in attending_member_ids end)

    socket
    |> assign(:organization, organization)
    |> assign(:meeting, meeting)
    |> assign(:attendees, attendees)
    |> assign(:uninvited_members, uninvited_members)
    |> assign(:agenda_items, agenda_items)
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, :show, _params) do
    {:noreply, socket |> assign(:page_title, "Show Meeting")}
  end

  def apply_action(socket, :new_agenda_item, _params) do
    form = %AgendaItem{} |> AgendaItem.changeset() |> to_form()

    positions =
      MeetingMinuet.Organizations.list_positions(socket.assigns.organization.id)
      |> Enum.map(&{&1.name, &1.id})

    {:noreply,
     socket
     |> assign(:page_title, "Add Agenda Item")
     |> assign(:positions, [{"None", nil} | positions])
     |> assign(:item_form, form)}
  end

  def apply_action(socket, :edit_agenda_item, _params) do
    form = %AgendaItem{} |> AgendaItem.changeset() |> to_form()

    {:noreply,
     socket
     |> assign(:page_title, "Edit Agenda Item")
     |> assign(:item_form, form)}
  end

  @impl true

  def handle_event("move_agenda_item_up", %{"id" => id}, socket) do
    IO.puts("MOVE AGENDA ITEM UP")

    Enum.find(socket.assigns.agenda_items, fn item -> item.id == id end)
    |> IO.inspect(label: "up: found item")
    |> Meetings.move_agenda_item_up()

    patch_to_meeting(socket)
  end

  def handle_event("move_agenda_item_down", %{"id" => id}, socket) do
    IO.puts("MOVE AGENDA ITEM DOWN")

    Enum.find(socket.assigns.agenda_items, fn item -> item.id == id end)
    |> IO.inspect(label: "down: found item")
    |> Meetings.move_agenda_item_down()

    patch_to_meeting(socket)
  end

  def handle_event("save_agenda_item", %{"agenda_item" => attrs}, socket) do
    Meetings.create_agenda_item!(Map.put(attrs, "meeting_id", socket.assigns.meeting.id))

    patch_to_meeting(socket)
  end

  def handle_event("delete_agenda_item", %{"id" => id}, socket) do
    Meetings.remove_agenda_item!(id)

    patch_to_meeting(socket)
  end

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
        {:noreply,
         push_navigate(
           socket,
           to:
             ~p"/organizations/#{socket.assigns.organization}/meetings/#{socket.assigns.meeting}/live"
         )}

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

  defp patch_to_meeting(socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/organizations/#{socket.assigns.organization}/meetings/#{socket.assigns.meeting}"
     )}
  end
end
