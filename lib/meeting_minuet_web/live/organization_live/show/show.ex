defmodule MeetingMinuetWeb.OrganizationLive.Show do
  use MeetingMinuetWeb, :live_view
  import MeetingMinuetWeb.DateComponents, warn: false
  import MeetingMinuetWeb.OrganizationLive.ShowComponents
  import MeetingMinuet.Organizations.Permissions

  alias MeetingMinuetWeb.DTO
  alias MeetingMinuet.Organizations.Presence
  alias MeetingMinuet.Organizations
  alias MeetingMinuet.Meetings.Meeting

  @impl true
  def mount(%{"organization_id" => org_id}, _session, socket) do
    connect_presence(socket, org_id)

    {:ok,
     assign(socket,
       presences: Presence.list_users(org_id)
     )
     |> assign_new(:organization, fn ->
       Organizations.get_fully_preloaded_organization!(socket.assigns.current_user, org_id)
     end)
     |> stream(:positions, [])
     |> stream(:meetings, [])
     |> stream(:members, [])}
  end

  @impl true
  def handle_params(params, _, %{assigns: %{organization: organization}} = socket) do
    socket
    |> stream(
      :positions,
      organization.positions
      |> DTO.Position.map_list()
    )
    |> stream(:meetings, organization.meetings)
    |> stream(
      :members,
      organization.memberships
      |> DTO.Member.map_list()
    )
    |> apply_action(socket.assigns.live_action, params)
  end

  # Apply Actions
  def apply_action(socket, action, _params) when action in [:new_position, :new_meeting] do
    socket =
      case action do
        :new_position ->
          socket
          |> assign(:position, %DTO.Position{})

        :new_meeting ->
          socket
          |> assign(:meeting, %Meeting{})
      end

    {:noreply, socket |> assign(:page_title, page_title(action))}
  end

  def apply_action(socket, :new_meeting, _params) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(:new_meeting))
     |> assign(:meeting, %Meeting{})}
  end

  def apply_action(socket, action, _params) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(action))}
  end

  # Handle Events
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff},
        socket
      ) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def handle_info({MeetingMinuetWeb.OrganizationLive.PositionForm, {:saved, position}}, socket) do
    {:noreply,
     stream_insert(
       socket,
       :positions,
       position
       |> Organizations.Positions.load_tenures()
       |> DTO.Position.map()
     )}
  end

  def handle_info(
        {MeetingMinuetWeb.OrganizationLive.OrganizationForm, {:saved, organization}},
        socket
      ) do
    Phoenix.PubSub.broadcast(
      MeetingMinuet.PubSub,
      organization.id,
      {:organization_saved, organization}
    )

    {:noreply, socket}
  end

  def handle_info(
        {MeetingMinuetWeb.OrganizationLive.InvitationForm, {:member_invited, membership}},
        socket
      ) do
    member = Organizations.get_member!(membership.id) |> DTO.Member.map_preloaded_membership()

    {:noreply, stream_insert(socket, :members, member)}
  end

  def handle_info({:organization_saved, organization}, socket) do
    {:noreply,
     socket
     |> assign(:organization, organization)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
  defp page_title(:new_position), do: "Create Position"
  defp page_title(:new_meeting), do: "Create Meeting"
  defp page_title(:invite_member), do: "Invite Member"

  defp page_title(action),
    do: "Organization #{action |> Atom.to_string() |> String.capitalize()} (unhandled)"

  defp connect_presence(socket, org_id) do
    if connected?(socket) do
      Presence.subscribe(org_id)

      %{current_user: current_user} = socket.assigns

      {:ok, _} =
        Presence.track_user(current_user, org_id, %{
          user_id: current_user.id
        })
    end

    socket
  end
end
