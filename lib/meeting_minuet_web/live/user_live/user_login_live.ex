defmodule MeetingMinuetWeb.UserLoginLive do
  use MeetingMinuetWeb, :live_view

  @registration_enabled Application.compile_env(:meeting_minuet, :registration_enabled)

  def render(assigns) do
    ~H"""
    <div class="mx-auto p-8 max-w-md bg-brand-100 rounded-lg border border-brand-300">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          <%= if @registration_enabled do %>
            Don't have an account?
            <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
              Sign up
            </.link>
            for an account now.
          <% end %>
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, registration_enabled: @registration_enabled),
     temporary_assigns: [form: form]}
  end
end
