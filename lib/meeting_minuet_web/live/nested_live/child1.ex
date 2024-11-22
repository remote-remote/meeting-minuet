defmodule MeetingMinuetWeb.NestedLive.Child1 do
  use MeetingMinuetWeb, :live_view

  def mount(params, session, socket) do
    IO.inspect(params, label: "Child 1 params")
    IO.inspect(session, label: "Child 1 session")
    IO.inspect(socket, label: "Child 1 socket")

    {:ok, assign(socket, pid: self())}
  end

  def render(assigns) do
    ~H"""
    <h1>Child 1</h1>
    <div>
      pid: <%= inspect(@pid) %>
    </div>
    <div>socket: <%= inspect(@socket) %></div>
    """
  end
end
