defmodule MeetingMinuetWeb.OrganizationLive.IndexComponents do
  import MeetingMinuet.Organizations.Permissions
  use MeetingMinuetWeb, :live_component
  import MeetingMinuetWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :organizations, :list, required: true
  attr :current_user, :map, required: true
  attr :title, :string, default: "Organizations"

  def organizations(assigns) do
    ~H"""
    <.header>
      <%= @title %>
      <:actions>
        <.link patch={~p"/organizations/new"}>
          <.button>Create</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="organizations"
      rows={@organizations}
      row_click={fn {_id, organization} -> JS.navigate(~p"/organizations/#{organization.id}") end}
    >
      <:col :let={{_id, organization}} label="Name"><%= organization.name %></:col>
      <:col :let={{_id, organization}} label="Description">
        <%= organization.description %>
      </:col>
      <:action :let={{_id, organization}}>
        <.link
          :if={edit_organization?(organization, @current_user)}
          patch={~p"/organizations/#{organization}/edit"}
        >
          Edit
        </.link>
      </:action>
      <:action :let={{id, organization}}>
        <.link
          :if={delete_organization?(organization, @current_user)}
          phx-click={JS.push("delete", value: %{id: organization.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  attr :upcoming_meetings, :list, required: true
  attr :organization, :map, required: true

  def upcoming_meetings(assigns) do
    ~H"""
    <.header>
      Upcoming Meetings
    </.header>
    <.table
      id="user_meetings"
      rows={@upcoming_meetings}
      row_click={
        fn {_id, meeting} ->
          JS.navigate(~p"/organizations/#{meeting.organization_id}/meetings/#{meeting.id}")
        end
      }
    >
      <:col :let={{_id, meeting}} label="Title">
        <%= meeting.title %>
      </:col>
      <:col :let={{_id, meeting}} label="Organization">
        <%= meeting.organization.name %>
      </:col>
      <:col :let={{_id, meeting}} label="Scheduled At">
        <%= meeting.date %> <%= meeting.scheduled_start_time %>
      </:col>
    </.table>
    """
  end
end
