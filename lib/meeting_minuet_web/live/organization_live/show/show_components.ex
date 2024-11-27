defmodule MeetingMinuetWeb.OrganizationLive.ShowComponents do
  use MeetingMinuetWeb, :live_component
  import MeetingMinuetWeb.CoreComponents
  import MeetingMinuetWeb.DateComponents
  import MeetingMinuet.Organizations.Permissions
  alias Phoenix.LiveView.JS

  attr :positions, :list, required: true
  attr :presences, :map, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true

  def positions_table(assigns) do
    ~H"""
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
    """
  end

  attr :meetings, :list, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true

  def meetings_table(assigns) do
    ~H"""
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
    """
  end

  attr :members, :list, required: true
  attr :organization, :map, required: true
  attr :membership, :map, required: true
  attr :presences, :map, required: true

  def members_table(assigns) do
    ~H"""
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
    """
  end
end
