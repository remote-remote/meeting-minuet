defmodule OrderWeb.OrganizationLive.ShowComponents do
  use OrderWeb, :live_component
  import OrderWeb.CoreComponents
  import OrderWeb.DateComponents
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
      <:col :let={position} label="Description"><%= position.description %></:col>
      <:col :let={position} label="Current Tenures">
        <%= position.current_tenures |> Enum.map(fn t -> t.name end) |> Enum.join(", ") %>
      </:col>
      <:col :let={position} label="Past Tenures">
        <%= position.past_tenures |> Enum.map(fn t -> t.name end) |> Enum.join(", ") %>
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
  attr :organization, :map, required: true
  attr :presences, :map, required: true

  def members(assigns) do
    ~H"""
    <.header>
      Members
      <:actions>
        <.link patch={~p"/organizations/#{@organization}/members/invite"}>
          <.button>New</.button>
        </.link>
      </:actions>
    </.header>
    <.table id="members" rows={@members}>
      <:col :let={member} label="Name"><%= member.name %></:col>
      <:col :let={member} label="Current Positions">
        <%= member.current_positions |> Enum.map(fn p -> p.name end) |> Enum.join(", ") %>
      </:col>
      <:col :let={member} label="Past Positions">
        <%= member.past_positions |> Enum.map(fn p -> p.name end) |> Enum.join(", ") %>
      </:col>
      <:col :let={member} label="Member Since">
        <.date_range_text date_range={member.active_range} type="start" />
      </:col>
      <:col :let={member} label="Online">
        <%= if member.user_id do %>
          <.icon
            name="hero-user-circle"
            class={
              if @presences[Integer.to_string(member.user_id)],
                do: "text-green-500",
                else: "text-slate-500"
            }
          />
        <% end %>
      </:col>
    </.table>
    """
  end
end
