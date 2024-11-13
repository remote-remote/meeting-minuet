defmodule OrderWeb.OrganizationLive.Show do
  use OrderWeb, :live_view

  alias Order.Organizations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    organization = Organizations.get_organization!(id, socket.assigns.current_user)

    socket
    |> assign(:organization, organization)
    |> assign(:positions, Organizations.list_positions(organization))
    |> apply_action(socket.assigns.live_action, params)
  end

  def apply_action(socket, :show, _params) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
    }
  end

  def apply_action(socket, :new_position, _params) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(:new_position))
     |> assign(:position, %Organizations.Position{})}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
  defp page_title(:new_position), do: "Create Position"
end
