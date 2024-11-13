defmodule OrderWeb.OrganizationLive.Show do
  use OrderWeb, :live_view
  import OrderWeb.DateComponents, warn: false

  alias Order.Organizations
  alias Order.Positions
  alias Order.Meetings
  alias Order.Presence

  @impl true
  def mount(%{"organization_id" => org_id}, _session, socket) do
    if connected?(socket) do
      connect_presence(socket, org_id)
    end

    topic = topic(org_id)

    {:ok, assign(socket, :presences, Presence.list_users(topic))}
  end

  @impl true
  def handle_params(%{"organization_id" => id} = params, _, socket) do
    organization = Organizations.get_organization!(socket.assigns.current_user, id)

    socket
    |> assign(:organization, organization)
    |> assign(:positions, Positions.list_positions(organization))
    |> assign(:meetings, Meetings.list_meetings(organization))
    |> apply_action(socket.assigns.live_action, params)
  end

  # Apply Actions
  def apply_action(socket, :show, _params) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
    }
  end

  def apply_action(socket, :edit, %{"id" => _}) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(:edit))}
  end

  def apply_action(socket, :new_position, _params) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(:new_position))
     |> assign(:position, %Positions.Position{})}
  end

  def apply_action(socket, :new_meeting, _params) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(:new_meeting))
     |> assign(:meeting, %Meetings.Meeting{})}
  end

  def apply_action(socket, :invite_members, %{"meeting_id" => meeting_id}) do
    # meeting = Meetings.get_meeting!(meeting_id, socket.assigns.current_user)
    # TODO: Implement this
    IO.puts("Invite members: meeting_id=#{meeting_id}")

    {:noreply, socket}
  end

  def apply_action(socket, action, _params) do
    IO.inspect(action, label: "Unhandled action")
    {:noreply, socket}
  end

  # Handle Events
  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff},
        socket
      ) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def handle_info({OrderWeb.PositionLive.FormComponent, {:saved, _position}}, socket) do
    {:noreply, socket}
  end

  def handle_info({OrderWeb.OrganizationLive.FormComponent, {:saved, organization}}, socket) do
    Phoenix.PubSub.broadcast(
      Order.PubSub,
      topic(organization.id),
      {:organization_saved, organization}
    )

    {:noreply, socket}
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

  defp topic(org_id) when is_bitstring(org_id) or is_integer(org_id) do
    "organization:#{org_id}"
  end

  defp connect_presence(socket, org_id) do
    if connected?(socket) do
      org_id |> topic() |> Presence.subscribe()

      %{current_user: current_user} = socket.assigns

      {:ok, _} =
        Presence.track_user(current_user, topic(org_id), %{
          user_id: current_user.id
        })
    end

    socket
  end
end
