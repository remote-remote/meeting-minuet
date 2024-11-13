defmodule OrderWeb.NestedLive.Parent do
  use OrderWeb, :live_view
  import OrderWeb.LayoutComponents

  def mount(_params, _session, socket) do
    {:ok, assign(socket, pid: self())}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    IO.puts("handle params")

    socket
    |> assign(%{child_session: %{"stuff" => ["thing1", "thing2"]}})
    |> assign_child(id)
  end

  def assign_child(socket, id) do
    case id do
      "child1" ->
        {:noreply, assign(socket, %{view: OrderWeb.NestedLive.Child1, id: id, pid: self()})}

      "child2" ->
        {:noreply, assign(socket, %{view: OrderWeb.NestedLive.Child2, id: id, pid: self()})}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid location, moving you to safety")
         |> push_patch(to: ~p"/nested/child1")}
    end
  end

  def render(assigns) do
    IO.inspect(assigns.view, label: "VIEW")

    ~H"""
    <.card>
      <.header>Child Selector</.header>
      <div>
        Parent: <%= inspect(@pid) %>
      </div>
      <div>
        <.link patch={~p"/nested/child1"}>Child 1</.link>
        <.link patch={~p"/nested/child2"}>Child 2</.link>
        <.link patch={~p"/nested/child3"}>Child 2</.link>
      </div>
    </.card>
    <.card>
      <.header>Child</.header>
      <div :if={@view}>
        <%= live_render(@socket, @view, id: @id, session: @child_session) %>
      </div>
    </.card>
    """
  end
end
