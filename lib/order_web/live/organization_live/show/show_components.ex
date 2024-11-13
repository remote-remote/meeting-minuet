defmodule OrderWeb.OrganizationLive.ShowComponents do
  use OrderWeb, :live_component
  import OrderWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :organization, :map, required: true

  def org_header(assigns) do
    ~H"""
    <.header class="py-4" text_class="text-4xl">
      <%= @organization.name %>
      <:subtitle><%= @organization.description %></:subtitle>
      <:actions>
        <.link patch={~p"/organizations/#{@organization}/edit"} phx-click={JS.push_focus()}>
          <.button class="w-20">Edit</.button>
        </.link>
      </:actions>
    </.header>
    """
  end

  attr :positions, :list, required: true
  attr :presences, :map, required: true
  attr :organization, :map, required: true

  def positions(assigns) do
    ~H"""
    <.header>
      Positions
      <:actions>
        <.link patch={~p"/organizations/#{@organization}/positions/new"}>
          <.button class="w-20">New</.button>
        </.link>
      </:actions>
    </.header>
    <.table
      id="positions"
      rows={@positions}
      row_click={fn row -> JS.navigate(~p"/organizations/#{@organization}/positions/#{row.id}") end}
    >
      <:col :let={position} label="Title"><%= position.name %></:col>
      <:col :let={position} label="Member">
        <%= if position.user.id do %>
          <%= position.user.name %>
        <% else %>
          Vacant
        <% end %>
      </:col>
      <:col :let={position} label="Online">
        <%= if position.user.id do %>
          <.icon
            name="hero-user-circle"
            class={
              if @presences[Integer.to_string(position.user.id)],
                do: "text-green-500",
                else: "text-slate-500"
            }
          />
        <% end %>
      </:col>
    </.table>
    """
  end

  attr :meetings, :list, required: true
  attr :organization, :map, required: true

  def meetings(assigns) do
    ~H"""
    <.header>
      Meetings
      <:actions>
        <.link patch={~p"/organizations/#{@organization}/meetings/new"}>
          <.button>New</.button>
        </.link>
      </:actions>
    </.header>
    <.table
      id="meetings"
      rows={@meetings}
      row_click={fn row -> JS.navigate(~p"/organizations/#{@organization}/meetings/#{row.id}") end}
    >
      <:col :let={meeting} label="Title"><%= meeting.title %></:col>
      <:col :let={meeting} label="Topic"><%= meeting.topic %></:col>
      <:col :let={meeting} label="Date"><%= meeting.date %></:col>
      <:col :let={meeting} label="Start"><%= meeting.scheduled_start_time %></:col>
      <:col :let={meeting} label="End"><%= meeting.scheduled_end_time %></:col>
      <:col :let={meeting} label="Location"><%= meeting.location %></:col>
    </.table>
    """
  end

  attr :members, :list, required: true

  def members(assigns) do
    ~H"""
    <.header>Members</.header>
    <.table id="members" rows={@members}>
      <:col :let={member} label="Name"><%= member.user.name %></:col>
      <:col :let={member} label="Email"><%= member.user.email %></:col>
      <:col :let={member} label="Positions">
        <%= member.positions |> Enum.map(fn p -> p.name end) |> Enum.join(", ") %>
      </:col>
    </.table>
    """
  end
end
