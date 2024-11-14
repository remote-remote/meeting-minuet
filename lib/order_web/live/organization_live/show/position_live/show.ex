defmodule OrderWeb.PositionLive.Show do
  use OrderWeb, :live_view
  import OrderWeb.LayoutComponents
  import OrderWeb.DateComponents
  alias OrderWeb.DTO
  alias Order.Organizations
  import Order.Organizations.Permissions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"organization_id" => org_id, "position_id" => position_id} = params,
        _,
        socket
      ) do
    organization = Organizations.get_organization!(socket.assigns.current_user, org_id)

    position =
      Organizations.get_position!(org_id, position_id) |> DTO.Position.map()

    socket
    |> assign(:organization, organization)
    |> assign(:position, position)
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, _action, _params) do
    {:noreply, socket}
  end
end
