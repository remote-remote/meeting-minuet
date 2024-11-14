defmodule OrderWeb.OrganizationLive.PositionForm do
  use OrderWeb, :live_component

  alias Order.Organizations

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="position-form"
        phx-target={@myself}
        phx-change="validate"
        phx-debounce="500"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:requires_report]} type="checkbox" label="Requires Report" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Position</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{position: %Organizations.Position{} = position} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Organizations.change_position(position))
     end)}
  end

  def update(%{position: %OrderWeb.DTO.Position{} = position} = assigns, socket) do
    position = OrderWeb.DTO.Position.unmap(position)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Organizations.change_position(position))
     end)}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset =
      socket.assigns.position
      |> OrderWeb.DTO.Position.unmap()
      |> Organizations.change_position(position_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params)
  end

  defp save_position(socket, :edit, position_params) do
    unmapped = OrderWeb.DTO.Position.unmap(socket.assigns.position)

    case Organizations.update_position(unmapped, position_params) do
      {:ok, position} ->
        notify_parent({:saved, position})

        {:noreply,
         socket
         |> put_flash(:info, "Position updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_position(socket, :new_position, position_params) do
    case Organizations.create_position(socket.assigns.organization, position_params) do
      {:ok, position} ->
        notify_parent({:saved, position})

        {:noreply,
         socket
         |> put_flash(:info, "Position created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
