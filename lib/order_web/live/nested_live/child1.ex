defmodule OrderWeb.NestedLive.Child1 do
  use OrderWeb, :live_view

  def mount(params, session, socket) do
    IO.inspect(params, label: "Child 1 params")
    IO.inspect(session, label: "Child 1 session")
    IO.inspect(socket, label: "Child 1 socket")

    {:ok, assign(socket, params: params, child1_pid: self())}
  end

  def render(assigns) do
    IO.inspect(assigns, label: "Child 1 render assigns")

    ~H"""
    <div>
      Child 1: <%= inspect(@child1_pid) %>
    </div>
    """
  end
end
