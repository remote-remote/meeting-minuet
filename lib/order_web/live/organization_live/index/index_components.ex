defmodule OrderWeb.OrganizationLive.IndexComponents do
  use OrderWeb, :live_component
  import OrderWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :organizations, :list, required: true
  attr :allow_actions, :boolean, default: true
  attr :title, :string, default: "Organizations"

  def organizations(assigns) do
    ~H"""
    <.header>
      <%= @title %>
      <:actions :if={@allow_actions}>
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
      <:action :let={{_id, organization}} :if={@allow_actions}>
        <div class="sr-only">
          <.link navigate={~p"/organizations/#{organization}"}>Show</.link>
        </div>
        <.link patch={~p"/organizations/#{organization}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, organization}} :if={@allow_actions}>
        <.link
          phx-click={JS.push("delete", value: %{id: organization.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end
end
