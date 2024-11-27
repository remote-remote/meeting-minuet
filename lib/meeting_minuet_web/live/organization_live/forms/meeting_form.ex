defmodule MeetingMinuetWeb.OrganizationLive.MeetingForm do
  use MeetingMinuetWeb, :live_component
  alias MeetingMinuet.Meetings

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="meeting-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} phx-debounce="500" type="text" label="Title" />
        <.input field={@form[:topic]} phx-debounce="500" type="text" label="Topic" />
        <.input field={@form[:date]} phx-debounce="500" type="date" label="Date" />
        <.input field={@form[:scheduled_start_time]} type="time" label="Start" />
        <.input field={@form[:scheduled_end_time]} type="time" label="End" />
        <.input field={@form[:location]} phx-debounce="500" label="Location" />
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
     |> assign(:members, nil)
     |> assign_new(:form, fn ->
       meeting
       |> Meetings.change_meeting()
       |> to_form()
     end)}
  end

  def handle_event(
        "validate",
        %{"meeting" => meeting_params},
        %{assigns: %{meeting: meeting}} = socket
      ) do
    form =
      meeting
      |> Meetings.change_meeting(meeting_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  # TODO: handle updating a meeting a different way, need to go to meeting invitations for new
  def handle_event("save", %{"meeting" => meeting_params}, socket) do
    save_meeting(socket, socket.assigns.action, meeting_params)
  end

  def handle_event(event, socket) do
    IO.inspect(event, label: "Unhandled event")
    {:noreply, socket}
  end

  def save_meeting(
        %{assigns: %{meeting: meeting, organization: organization}} =
          socket,
        :edit,
        attrs
      ) do
    case Meetings.update_meeting(meeting, attrs) do
      {:ok, saved_meeting} ->
        notify_parent({:saved, saved_meeting})

        {:noreply,
         socket
         |> put_flash(:info, "Meeting created successfully")
         |> push_navigate(to: ~p"/organizations/#{organization}/meetings/#{saved_meeting.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  def save_meeting(
        %{assigns: %{organization: organization, membership: membership}} =
          socket,
        :new_meeting,
        attrs
      ) do
    case Meetings.create_meeting(organization, membership, attrs) do
      {:ok, saved_meeting} ->
        notify_parent({:saved, saved_meeting})

        {:noreply,
         socket
         |> put_flash(:info, "Meeting created successfully")
         |> push_navigate(to: ~p"/organizations/#{organization}/meetings/#{saved_meeting.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
