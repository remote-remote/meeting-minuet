defmodule MeetingMinuetWeb.NestedLive.Child2 do
  use MeetingMinuetWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, assign(socket, params: params, pid: self())}
  end

  def render(assigns) do
    IO.inspect(assigns, label: "Child 2 assigns")

    ~H"""
    <div>
      Child 2: <%= inspect(@pid) %>
    </div>
    """
  end
end
