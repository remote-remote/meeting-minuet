defmodule MeetingMinuetWeb.OrganizationLive.Index do
  use MeetingMinuetWeb, :live_view
  import MeetingMinuet.Organizations.Permissions

  alias MeetingMinuet.Organizations
  alias MeetingMinuet.Organizations.Organization

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    socket =
      socket
      |> stream(:organizations, Organizations.list_organizations(current_user))
      |> stream(
        :upcoming_meetings,
        MeetingMinuet.Meetings.list_user_meetings(current_user.id, status: :scheduled)
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"organization_id" => id}) do
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
        {MeetingMinuetWeb.OrganizationLive.OrganizationForm, {:saved, organization}},
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
    organization = Organizations.get_organization!(socket.assigns.current_user, id)
    {:ok, _} = Organizations.delete_organization(organization)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end
end
