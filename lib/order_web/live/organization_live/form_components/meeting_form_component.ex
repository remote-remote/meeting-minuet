defmodule OrderWeb.OrganizationLive.MeetingFormComponent do
  use OrderWeb, :live_component
  alias Order.Meetings

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="meeting-form"
        phx-target={@myself}
        phx-change="validate"
        phx-debounce="500"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:topic]} type="text" label="Topic" />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:scheduled_start_time]} type="time" label="Start" />
        <.input field={@form[:scheduled_end_time]} type="time" label="End" />
        <.input field={@form[:location]} label="Location" />
        <.input
          field={@form[:timezone]}
          type="select"
          label="Time Zone"
          options={["America/New_York", "America/Chicago"]}
          value={@form[:timezone].value || "America/Chicago"}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Meeting</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{meeting: meeting} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Meetings.change_meeting(meeting)) end)}
  end

  def handle_event(
        "validate",
        %{"meeting" => meeting_params},
        %{assigns: %{meeting: meeting}} = socket
      ) do
    form =
      meeting
      |> Meetings.change_meeting(meeting_params)
      |> IO.inspect(label: "Meeting Changeset")
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"meeting" => meeting_params}, socket) do
    save_meeting(socket, socket.assigns.action, meeting_params)
  end

  def save_meeting(
        %{assigns: %{organization: organization}} = socket,
        :new_meeting,
        meeting_params
      ) do
    case Meetings.create_meeting(meeting_params, organization) do
      {:ok, meeting} ->
        notify_parent({:saved, meeting})

        {:noreply,
         socket
         |> put_flash(:info, "Meeting created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
