defmodule MeetingMinuetWeb.ChatChannel do
  use Phoenix.Channel
  alias MeetingMinuet.Chats
  alias MeetingMinuet.Organizations
  alias MeetingMinuet.Meetings

  def join("chat:group:" <> chat_group_id, %{"userToken" => user_token}, socket) do
    chat_group_id = String.to_integer(chat_group_id)

    with {:ok, user_id} <- Phoenix.Token.verify(MeetingMinuetWeb.Endpoint, "user", user_token),
         user <- MeetingMinuet.Accounts.get_user!(user_id),
         true <- Chats.is_member?(chat_group_id, user.id) do
      {:ok,
       assign(socket, current_user: user, chattable_type: :group, chattable_id: chat_group_id)}
    else
      {:error, _} -> {:error, %{reason: "Invalid user token"}}
      false -> {:error, %{reason: "You are not a member of this chat group"}}
    end

    {:ok, assign(socket, chattable_type: :group, chattable_id: chat_group_id)}
  end

  def join("chat:meeting:" <> meeting_id, %{"userToken" => user_token}, socket) do
    meeting_id = String.to_integer(meeting_id)

    with {:ok, user_id} <- Phoenix.Token.verify(MeetingMinuetWeb.Endpoint, "user", user_token),
         user <- MeetingMinuet.Accounts.get_user!(user_id),
         true <- Meetings.is_attendee?(meeting_id, user.id) do
      {:ok,
       assign(socket, current_user: user, chattable_type: :meeting, chattable_id: meeting_id)}
    else
      {:error, _} -> {:error, %{reason: "Invalid user token"}}
      false -> {:error, %{reason: "You are not an attendee of this meeting"}}
    end
  end

  def join("chat:organization:" <> org_id, %{"userToken" => user_token}, socket) do
    org_id = String.to_integer(org_id)

    with {:ok, user_id} <- Phoenix.Token.verify(MeetingMinuetWeb.Endpoint, "user", user_token),
         user <- MeetingMinuet.Accounts.get_user!(user_id),
         true <- Organizations.is_member?(org_id, user_id) do
      {:ok,
       assign(socket, current_user: user, chattable_type: :organization, chattable_id: org_id)}
    else
      {:error, _} -> {:error, %{reason: "Invalid user token"}}
      false -> {:error, %{reason: "You are not a member of this organization"}}
    end
  end

  # Handle incoming messages
  def handle_in("new_message", %{"body" => body}, socket) do
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

        {:reply,
         {:ok,
          %{
            user_id: user.id,
            user_name: user.name,
            body: message.body
          }}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
