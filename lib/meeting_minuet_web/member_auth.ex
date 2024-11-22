defmodule MeetingMinuetWeb.OrgMemberAuth do
  use MeetingMinuetWeb, :verified_routes
  import Plug.Conn
  alias MeetingMinuet.Organizations

  def fetch_membership(
        %{
          assigns: %{current_user: current_user},
          params: %{"organization_id" => organization_id}
        } = conn,
        _opts
      ) do
    case Organizations.get_membership(organization_id, current_user.id) do
      %Organizations.Membership{} = membership ->
        assign(conn, :current_membership, membership)

      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "You are not a member of that organization.")
        |> Phoenix.Controller.redirect(to: ~p"/organizations")
    end
  end

  def mount_membership(socket, %{"organization_id" => org_id}) do
    Phoenix.Component.assign_new(socket, :current_membership, fn ->
      Organizations.get_membership(org_id, socket.assigns.current_user.id)
    end)
  end

  def on_mount(:ensure_membership, params, _session, socket) do
    socket = mount_membership(socket, params)

    if socket.assigns.current_membership do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You are not a member of this organization.")
        |> Phoenix.LiveView.redirect(to: ~p"/organizations")

      {:halt, socket}
    end

    {:cont, socket}
  end
end
