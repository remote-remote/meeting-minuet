defmodule MeetingMinuetWeb.UserInvitationLive do
  use MeetingMinuetWeb, :live_view

  alias MeetingMinuet.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Invitation</.header>

      <.simple_form for={@form} id="accept_invitation_form" phx-submit="accept_invitation">
        <.input type="text" field={@form[:name]} label="Name" />
        <.input type="password" field={@form[:password]} label="Password" />
        <.input type="password" field={@form[:password_confirmation]} label="Password confirmation" />

        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <:actions>
          <.button phx-disable-with="Accepting..." class="w-full">Accept Invitation</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    case Accounts.get_user_by_invitation_token(token) do
      {:ok, user} ->
        {:ok,
         socket
         |> assign(:token, token)
         |> assign(:form, user |> Accounts.change_user_registration() |> to_form())}

      _ ->
        {:ok, socket |> put_flash(:error, "Invalid invitation token!") |> redirect(to: ~p"/")}
    end
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("accept_invitation", %{"user" => user_attrs}, socket) do
    case Accounts.accept_invitation(socket.assigns[:token], user_attrs) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You have accepted your invitation!")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
