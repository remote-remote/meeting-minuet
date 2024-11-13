defmodule OrderWeb.OrganizationLive.InvitationFormComponent do
  use OrderWeb, :live_component

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
        <.input field={@form[:email]} type="email" label="Email" />
        <:actions>
          <.button phx-disable-with="Sending...">Invite</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    IO.inspect(assigns, label: "InvitationFormComponent update assigns")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :form,
       OrderWeb.Dtos.MemberInvitation.changeset(%OrderWeb.Dtos.MemberInvitation{}, %{})
       |> to_form()
     )}
  end

  def send_invitation(
        %{assigns: %{organization: organization}} = socket,
        attrs
      ) do
    IO.inspect(attrs, label: "InvitationFormComponent send_invitation")

    case Order.Organizations.Members.invite_member(organization, attrs) do
      {:ok, member} ->
        notify_parent({:member_invited, member})
        {:noreply, socket |> assign(:form, %OrderWeb.Dtos.MemberInvitation{})}

      {:error, changeset} ->
        {:noreply, socket |> assign(:form, changeset)}
    end

    {:noreply, socket}
  end

  def handle_event(
        "validate",
        _params,
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event("save", %{"member_invitation" => invitation_params}, socket) do
    IO.puts("InvitationFormComponent handle_event save")
    send_invitation(socket, invitation_params)
  end

  def handle_event(event, socket) do
    IO.inspect(event, label: "Unhandled event")
    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
