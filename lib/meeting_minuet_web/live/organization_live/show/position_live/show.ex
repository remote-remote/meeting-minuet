defmodule MeetingMinuetWeb.PositionLive.Show do
  use MeetingMinuetWeb, :live_view
  import MeetingMinuetWeb.LayoutComponents
  import MeetingMinuetWeb.DateComponents
  alias MeetingMinuetWeb.DTO
  alias MeetingMinuet.Organizations
  import MeetingMinuet.Organizations.Permissions

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

  def apply_action(socket, :edit_tenure, %{"tenure_id" => tenure_id, "organization_id" => org_id}) do
    tenure = Organizations.get_tenure!(org_id, tenure_id)
    {:noreply, assign(socket, tenure: tenure, page_title: page_title(socket))}
  end

  def apply_action(socket, :new_tenure, %{"position_id" => position_id}) do
    {:noreply,
     assign(socket, :tenure, %Organizations.Tenure{position_id: position_id})
     |> assign(:page_title, page_title(socket))}
  end

  def apply_action(socket, _action, _params) do
    {:noreply, assign(socket, :page_title, page_title(socket))}
  end

  defp page_title(%{assigns: %{live_action: :edit_tenure, position: position}}) do
    "Edit Tenure for #{position.name}"
  end

  defp page_title(%{assigns: %{live_action: :new_tenure, position: position}}) do
    "New Tenure for #{position.name}"
  end

  defp page_title(%{assigns: %{position: position}}) do
    position.name
  end
end
