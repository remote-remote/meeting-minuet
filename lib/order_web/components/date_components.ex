defmodule OrderWeb.DateComponents do
  use Phoenix.Component

  attr :date_range, :map, required: true
  attr :type, :string, default: "range"

  def date_range_text(%{type: "range", date_range: %Postgrex.Range{}} = assigns) do
    ~H"""
    <.date_range_text date_range={@date_range} type="start" /> -
    <.date_range_text date_range={@date_range} type="end" />
    """
  end

  def date_range_text(%{type: "start", date_range: %Postgrex.Range{}} = assigns) do
    ~H"""
    <%= if is_nil(@date_range.lower) or @date_range.lower == :unbound,
      do: "All Time",
      else: @date_range.lower %>
    """
  end

  def date_range_text(%{type: "end", date_range: %Postgrex.Range{}} = assigns) do
    ~H"""
    <%= if is_nil(@date_range.upper) or @date_range.upper == :unbound,
      do: "Present",
      else: @date_range.upper %>
    """
  end
end
