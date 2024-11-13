defmodule OrderWeb.DateComponents do
  use Phoenix.Component

  attr :date_range, :map, required: true

  def date_range_display(assigns) do
    ~H"""
    <span>
      <%= if @date_range.lower != :unbound do %>
        <%= Calendar.strftime(@date_range.lower, "%Y-%m-%d %I:%M %p") %>
      <% end %>
      -
      <%= if @date_range.upper != :unbound do %>
        <%= Calendar.strftime(@date_range.upper, "%Y-%m-%d %I:%M %p") %>
      <% end %>
    </span>
    """
  end
end
