defmodule OrderWeb.PositionLive.AssignForm do
  use OrderWeb, :live_component
  alias OrderWeb.DTO
  alias Order.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Assign <%= @position.name %>
      </.header>
      <.simple_form
        for={@form}
        id="assign-form"
        phx-target={@myself}
        phx-change="validate"
        phx-debounce="500"
        phx-submit="save"
      >
        <.input
          field={@form[:membership_id]}
          type="select"
          label="Member"
          options={@members}
          value={@form[:membership_id].value}
        />
        <.input field={@form[:start_date]} type="date" label="Start Date" />
        <.input field={@form[:end_date]} type="date" label="End Date" />

        <:actions>
          <.button phx-disable-with="Saving...">Assign</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{organization: organization, position: position, tenure: tenure} = assigns, socket) do
    # TODO: We need to either take the memberships out of organizations or add the user to it
    members =
      Organizations.list_members(organization.id)
      |> DTO.Member.map_list()
      |> Enum.map(&{&1.name, &1.id})
    form = DTO.Tenure.changeset(tenure, %{}) |> to_form()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(position: position, members: members, tenure: tenure)
     |> assign_new(:form, fn -> form end)}
  end

  @impl true
  def handle_event("validate", %{"tenure" => form_params}, %{assigns: %{tenure: tenure}} = socket) do
    form =
      tenure
      |> DTO.Tenure.changeset(form_params)
      |> to_form(action: :validate)
      |> IO.inspect(label: "tenure form validate")

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"tenure" => form_params}, socket) do
    save_tenure(socket, socket.assigns.tenure, form_params)
  end

  def save_tenure(%{assigns: assigns} = socket, tenure, attrs) do
    case DTO.Tenure.unmap_attrs(tenure, attrs) |> Organizations.create_tenure() do
      {:ok, _} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/organizations/#{assigns.organization}/positions/#{assigns.position}"
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end
end
