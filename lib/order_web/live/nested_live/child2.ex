defmodule OrderWeb.NestedLive.Child2 do
  use OrderWeb, :live_view
  import OrderWeb.LayoutComponents

  def mount(params, _session, socket) do
    {:ok, assign(socket, params: params, child1_pid: self())}
  end

  def render(assigns) do
    IO.inspect(assigns, label: "Child 2 assigns")

    ~H"""
    <div>
      Child 2: <%= inspect(@child1_pid) %>
    </div>
    """
  end
end
