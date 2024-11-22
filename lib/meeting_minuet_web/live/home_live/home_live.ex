defmodule MeetingMinuetWeb.HomeLive.Home do
  use MeetingMinuetWeb, :live_view
  alias MeetingMinuet.Organizations

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    organizations = Organizations.list_organizations(current_user)

    org_options =
      organizations
      |> Enum.map(&%{id: &1.id, name: &1.name})

    {:ok, assign(socket, :org_options, org_options)}
  end
end
