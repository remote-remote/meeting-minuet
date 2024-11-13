defmodule OrderWeb.OrganizationLive.Index do
  use OrderWeb, :live_view
  import OrderWeb.LayoutComponents
  import OrderWeb.OrganizationLive.IndexComponents

  alias Order.Organizations
  alias Order.DB.Organization

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    socket =
      socket
      |> stream(:owned_organizations, Organizations.owned_organizations(current_user))
      |> stream(:member_organizations, Organizations.member_organizations(current_user))
      |> assign(
        :upcoming_meetings,
        Order.Meetings.list_meetings(current_user, status: :scheduled)
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, Organizations.get_organization!(socket.assigns.current_user, id))
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
    {:noreply, stream_insert(socket, :owned_organizations, organization)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization = Organizations.get_organization!(socket.assigns.current_user, id)
    {:ok, _} = Organizations.delete_organization(organization)

    {:noreply, stream_delete(socket, :owned_organizations, organization)}
  end
end
