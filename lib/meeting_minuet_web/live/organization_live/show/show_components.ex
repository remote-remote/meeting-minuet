defmodule MeetingMinuetWeb.OrganizationLive.ShowComponents do
  use MeetingMinuetWeb, :live_component
  import MeetingMinuet.Organizations.Permissions
  import MeetingMinuetWeb.CoreComponents
  import MeetingMinuetWeb.DateComponents
  alias Phoenix.LiveView.JS

  attr :organization, :map, required: true
  attr :current_user, :map, required: true
  attr :membership, :map, required: true
  attr :chat_messages, :list, default: []

  def org_header(assigns) do
    ~H"""
    <.header text_class="text-3xl">
      <%= @organization.name %>

      <:subtitle>
        <%= @organization.description %>
      </:subtitle>
      <:actions>
        <.link
          :if={edit_organization?(@organization, @membership)}
          patch={~p"/organizations/#{@organization}/show/edit"}
          phx-click={JS.push_focus()}
        >
          <.icon name="hero-pencil" class="w-5 h-5" />
        </.link>
      </:actions>
    </.header>
    """
  end

  attr :positions, :list, required: true
  attr :presences, :map, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true

  def positions(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <.header>
        Positions
        <:actions>
          <.link
            :if={create_positions?(@organization, @membership)}
            patch={~p"/organizations/#{@organization}/positions/new"}
          >
            <.icon name="hero-plus" class="w-5 h-5" />
          </.link>
        </:actions>
      </.header>
      <div class="flex-grow overflow-y-auto">
        <.table
          id="positions"
          rows={@positions}
          row_click={
            fn {_id, row} -> JS.navigate(~p"/organizations/#{@organization}/positions/#{row.id}") end
          }
        >
          <:col :let={{_id, position}} label="Title"><%= position.name %></:col>
          <:col :let={{_id, position}} label="Description"><%= position.description %></:col>
          <:col :let={{_id, position}} label="Current Tenures">
            <%= position.current_tenures |> Enum.map(fn t -> t.name end) |> Enum.join(", ") %>
          </:col>
          <:col :let={{_id, position}} label="Past Tenures">
            <%= position.past_tenures |> Enum.map(fn t -> t.name end) |> Enum.join(", ") %>
          </:col>
        </.table>
      </div>
    </div>
    """
  end

  attr :meetings, :list, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true

  def meetings(assigns) do
    ~H"""
    <div class="flex flex-col">
      <.header>
        Meetings
        <:actions>
          <.link
            :if={create_meetings?(@organization, @membership)}
            patch={~p"/organizations/#{@organization}/meetings/new"}
          >
            <.icon name="hero-plus" class="w-5 h-5" />
          </.link>
        </:actions>
      </.header>
      <div class="flex-grow overflow-y-auto">
        <.table
          id="meetings"
          rows={@meetings}
          row_click={
            fn {_id, row} -> JS.navigate(~p"/organizations/#{@organization}/meetings/#{row.id}") end
          }
        >
          <:col :let={{_id, meeting}} label="Title"><%= meeting.title %></:col>
          <:col :let={{_id, meeting}} label="Topic"><%= meeting.topic %></:col>
          <:col :let={{_id, meeting}} label="Date"><%= meeting.date %></:col>
          <:col :let={{_id, meeting}} label="Start"><%= meeting.scheduled_start_time %></:col>
          <:col :let={{_id, meeting}} label="End"><%= meeting.scheduled_end_time %></:col>
          <:col :let={{_id, meeting}} label="Location"><%= meeting.location %></:col>
        </.table>
      </div>
    </div>
    """
  end

  attr :members, :list, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true
  attr :presences, :map, required: true

  def members(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <.header>
        Members
        <:actions>
          <.link
            :if={add_members?(@organization, @membership)}
            patch={~p"/organizations/#{@organization}/members/invite"}
          >
            <.icon name="hero-plus" class="w-5 h-5" />
          </.link>
        </:actions>
      </.header>
      <div class="flex-grow overflow-y-auto">
        <.table id="members" rows={@members}>
          <:col :let={{_id, member}} label="Name"><%= member.name %></:col>
          <:col :let={{_id, member}} label="Current Positions">
            <%= member.current_positions |> Enum.map(fn p -> p.name end) |> Enum.join(", ") %>
          </:col>
          <:col :let={{_id, member}} label="Past Positions">
            <%= member.past_positions |> Enum.map(fn p -> p.name end) |> Enum.join(", ") %>
          </:col>
          <:col :let={{_id, member}} label="Member Since">
            <.date_range_text date_range={member.active_range} type="start" />
          </:col>
          <:col :let={{_id, member}} label="Online">
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
      </div>
    </div>
    """
  end
end
