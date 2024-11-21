defmodule OrderWeb.OrganizationLive.Show do
  alias Order.Chats
  use OrderWeb, :live_view
  import OrderWeb.DateComponents, warn: false
  import OrderWeb.LayoutComponents
  import OrderWeb.OrganizationLive.ShowComponents

  alias OrderWeb.DTO
  alias Order.Organizations.Presence
  alias Order.{Meetings, Organizations}
  alias Order.Meetings.Meeting

  @impl true
  def mount(%{"organization_id" => org_id}, _session, socket) do
    connect_presence(socket, org_id)
    user_token = Phoenix.Token.sign(OrderWeb.Endpoint, "user", socket.assigns.current_user.id)

    recent_messages =
      Chats.list_messages("organization", org_id)
      |> Enum.map(
        &%{
          "user_name" => &1.user.name,
          "user_id" => &1.user.id,
          "body" => &1.body
        }
      )

    {:ok,
     assign(socket,
       presences: Presence.list_users(org_id),
       user_token: user_token,
       chat_messages: recent_messages
     )}
  end

  @impl true
  def handle_params(%{"organization_id" => org_id} = params, _, socket) do
    organization = Organizations.get_organization!(socket.assigns.current_user, org_id)

    socket
    |> assign(:organization, organization)
    |> assign(
      :positions,
      Organizations.list_positions(org_id)
      |> DTO.Position.map_list()
    )
    |> assign(:meetings, Meetings.list_org_meetings(org_id))
    |> assign(
      :members,
      Organizations.list_members(org_id)
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

  def handle_info({OrderWeb.PositionLive.FormComponent, {:saved, _position}}, socket) do
    {:noreply, socket}
  end

  def handle_info({OrderWeb.OrganizationLive.FormComponent, {:saved, organization}}, socket) do
    Phoenix.PubSub.broadcast(
      Order.PubSub,
      organization.id,
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

  @impl true
  def handle_event("new_message", payload, socket) do
    {:noreply, update(socket, :chat_messages, &(&1 ++ [payload]))}
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
