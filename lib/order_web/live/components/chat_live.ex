defmodule OrderWeb.ChatComponent do
  use OrderWeb, :live_component
  alias Order.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={"#{@chattable_type}-#{@chattable_id}"}
      data-chat-id={"#{@chattable_type}:#{@chattable_id}"}
      phx-hook="Chat"
      class="h-full flex flex-col"
      phx-target={@myself}
    >
      <.header>
        <%= @title %>
      </.header>
      <div class="flex-grow overflow-y-auto flex flex-col-reverse">
        <%= for message <- @chat_messages do %>
          <div class={[
            if(message["user_id"] == @current_user.id,
              do: "place-self-end bg-slate-200",
              else: "place-self-start bg-brand-200"
            ),
            "my-4 p-2 border rounded-md background-slate-100"
          ]}>
            <span class="font-bold"><%= message["user_name"] %>:</span>
            <span><%= message["body"] %></span>
          </div>
        <% end %>
      </div>
      <form id="message-form" class="mt-4">
        <div class="flex gap-2">
          <input id="message-input" name="message" value="" class="flex-grow border rounded p-2" />
          <.button class="w-auto my-4" phx-click="">Send</.button>
        </div>
      </form>
      <script>
        if (window.__mmState == null) {
        window.__mmState = {};
        }
        window.__mmState.userToken = "<%= @user_token %>";
      </script>
    </div>
    """
  end

  @impl true
  def update(
        %{chattable_type: chattable_type, chattable_id: chattable_id} = assigns,
        socket
      ) do
    user_token = Phoenix.Token.sign(OrderWeb.Endpoint, "user", assigns.current_user.id)

    recent_messages =
      Chats.list_messages(chattable_type, chattable_id, 20)
      |> Enum.map(
        &%{
          "user_name" => &1.user.name,
          "user_id" => &1.user.id,
          "body" => &1.body
        }
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:chat_messages, recent_messages)
     |> assign(:user_token, user_token)}
  end

  @impl true
  def handle_event("new_message", payload, socket) do
    IO.inspect(payload, label: "ChatComponent new message")
    {:noreply, update(socket, :chat_messages, &([payload] ++ &1))}
  end
end
