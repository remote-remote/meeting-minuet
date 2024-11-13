defmodule OrderWeb.OrganizationLive.InvitationForm do
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :form,
       OrderWeb.Dtos.MemberInvitation.changeset(%OrderWeb.Dtos.MemberInvitation{}, %{})
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
    case Order.Organizations.invite_member(
           organization,
           &url(~p"/users/accept_invitation/#{&1}"),
           attrs
         ) do
      {:ok, member} ->
        notify_parent({:member_invited, member})

        {:noreply,
         socket
         |> push_navigate(to: ~p"/organizations/#{organization.id}")}

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
