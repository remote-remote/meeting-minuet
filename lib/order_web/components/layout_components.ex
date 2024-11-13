defmodule OrderWeb.LayoutComponents do
  use Phoenix.Component

  attr :rows, :integer, required: true
  attr :cols, :integer, required: true
  attr :class, :string, default: ""
  attr :gap, :integer, default: 4
  slot :inner_block, required: true

  def grid(assigns) do
    ~H"""
    <div class={"grid grid-cols-#{@cols} grid-rows-#{@rows} gap-#{@gap} #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :row, :integer
  attr :col, :integer
  attr :width, :integer
  attr :height, :integer
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def grid_cell(assigns) do
    ~H"""
    <div class={grid_cell_classes(assigns)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={"bg-brand-50 border border-brand-200 shadow-md rounded-lg p-6 #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp grid_cell_classes(assigns) do
    mapper = %{
      row: "row-start-",
      col: "col-start-",
      width: "col-span-",
      height: "row-span-",
      class: ""
    }

    Map.take(assigns, [:col, :row, :width, :height, :class])
    |> Enum.map(fn {k, v} -> "#{mapper[k]}#{v}" end)
  end
end
