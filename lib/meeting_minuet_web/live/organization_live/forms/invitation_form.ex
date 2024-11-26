defmodule MeetingMinuetWeb.OrganizationLive.InvitationForm do
  use MeetingMinuetWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="invitation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-debounce="500"
        phx-submit="save"
      >
        <.input field={@form[:name]} phx-debounce="500" type="text" label="Name" />
        <.input field={@form[:email]} phx-debounce="500" type="email" label="Email" />
        <:actions>
          <.button phx-disable-with="Sending...">Invite</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :form,
       MeetingMinuetWeb.DTO.MemberInvitation.changeset(
         %MeetingMinuetWeb.DTO.MemberInvitation{},
         %{}
       )
       |> to_form()
     )}
  end

  def handle_event(
        "validate",
        _params,
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event("save", %{"member_invitation" => invitation_params}, socket) do
    send_invitation(socket, invitation_params)
  end

  def send_invitation(
        %{assigns: %{organization: organization}} = socket,
        attrs
      ) do
    case MeetingMinuet.Organizations.invite_member(
           organization,
           &url(~p"/users/accept_invitation/#{&1}"),
           attrs
         ) do
      {:ok, member} ->
        notify_parent({:member_invited, member})

        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, socket |> assign(:form, changeset)}
    end
  end

  def handle_event(event, socket) do
    IO.inspect(event, label: "Unhandled event")
    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
