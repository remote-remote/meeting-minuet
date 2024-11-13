defmodule OrderWeb.OrganizationLive.Index do
  use OrderWeb, :live_view

  alias Order.Organizations
  alias Order.Organizations.Organization

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns
    {:ok, stream(socket, :organizations, Organizations.list_organizations(current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, Organizations.get_organization!(id, socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, %Organization{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_info(
        {OrderWeb.OrganizationLive.OrganizationFormComponent, {:saved, organization}},
        socket
      ) do
    {:noreply, stream_insert(socket, :organizations, organization)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization = Organizations.get_organization!(id, socket.assigns.current_user)
    {:ok, _} = Organizations.delete_organization(organization)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end
end
