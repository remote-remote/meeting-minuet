defmodule OrderWeb.ChatChannel do
  use Phoenix.Channel
  alias Order.Chats
  alias Order.Organizations
  alias Order.Meetings

  def join("chat:group:" <> chat_group_id, _params, socket) do
    chat_group_id = String.to_integer(chat_group_id)
    user = socket.assigns.current_user

    case Chats.is_member?(chat_group_id, user.id) do
      true ->
        {:ok, assign(socket, :chat_group_id, chat_group_id)}

      false ->
        {:error, %{reason: "You are not a member of this group"}}
    end

    {:ok, assign(socket, chattable_type: :group, chattable_id: chat_group_id)}
  end

  def join("chat:meeting:" <> meeting_id, _params, socket) do
    meeting_id = String.to_integer(meeting_id)
    user = socket.assigns.current_user

    case Meetings.is_attendee?(meeting_id, user.id) do
      true ->
        {:ok, assign(socket, chattable_type: :meeting, chattable_id: meeting_id)}

      false ->
        {:error, %{reason: "You are not an attendee of this meeting"}}
    end
  end

  def join("chat:organization:" <> org_id, %{"userToken" => user_token}, socket) do
    org_id = String.to_integer(org_id)

    case Phoenix.Token.verify(OrderWeb.Endpoint, "user", user_token) do
      {:ok, user_id} ->
        user = Order.Accounts.get_user!(user_id)

        case Organizations.is_member?(org_id, user.id) do
          true ->
            {:ok,
             assign(socket,
               chattable_type: :organization,
               chattable_id: org_id,
               current_user: user
             )}

          false ->
            {:error, %{reason: "You are not a member of this organization"}}
        end

      _ ->
        {:error, %{reason: "Invalid user token"}}
    end
  end

  # Handle incoming messages
  def handle_in("new_message", %{"body" => body}, socket) do
    IO.inspect(socket.assigns, label: "new message assigns")
    user = socket.assigns.current_user
    # Store the message in your business context
    case Chats.create_message(%{
           chattable_type: socket.assigns.chattable_type,
           chattable_id: socket.assigns.chattable_id,
           user_id: user.id,
           body: body
         }) do
      {:ok, message} ->
        # Broadcast the message to all channel subscribers
        broadcast!(socket, "new_message", %{
          user_id: user.id,
          user_name: user.name,
          body: message.body
        })

        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
