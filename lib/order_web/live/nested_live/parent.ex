defmodule OrderWeb.NestedLive.Parent do
  use OrderWeb, :live_view
  import OrderWeb.LayoutComponents

  def mount(params, _session, socket) do
    {:ok, assign(socket, params: params, from_parent: %{stuff: ["F", "U"]})}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :child1, params) do
    socket
    |> assign(:params, params)
    |> assign(:parent_pid, self())
    |> assign(:view, OrderWeb.NestedLive.Child1)
  end

  defp apply_action(socket, :child2, params) do
    socket
    |> assign(:params, params)
    |> assign(:parent_pid, self())
    |> assign(:view, OrderWeb.NestedLive.Child2)
  end

  def render(assigns) do
    IO.inspect(assigns, label: "Parent render assigns")
    IO.inspect(assigns.socket, label: "Parent render socket")

    ~H"""
    <.header>
      <%= live_render(@socket, @view, id: "live_vie_render", assigns: %{from_parent: @from_parent}) %>
    </.header>
    <div>
      Parent: <%= inspect(@parent_pid) %>
    </div>
    """
  end
end
