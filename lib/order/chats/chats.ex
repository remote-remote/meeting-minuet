defmodule Order.Chats do
  alias Order.Chats.ChatGroup
  alias Order.Chats.ChatGroupMember
  alias Order.Chats.ChatMessage
  alias Order.Repo
  import Ecto.Query

  def create_chat_group(attrs) do
    %ChatGroup{}
    |> ChatGroup.changeset(attrs)
    |> Repo.insert()
  end

  def add_member(group_id, user_id) do
    attrs = %{
      chat_group_id: group_id,
      user_id: user_id
    }

    case %ChatGroupMember{}
         |> ChatGroupMember.changeset(attrs)
         |> Repo.insert() do
      {:ok, chat_member} -> {:ok, chat_member}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def is_member?(group_id, user_id) do
    member =
      ChatGroupMember
      |> where([m], m.chat_group_id == ^group_id and m.user_id == ^user_id)
      |> Repo.one()

    !is_nil(member)
  end

  def create_message(attrs) do
    %ChatMessage{}
    |> ChatMessage.changeset(attrs)
    |> Repo.insert()
  end

  def add_member!(chat_id, user_id) do
    case add_member(chat_id, user_id) do
      {:ok, chat_member} -> chat_member
      {:error, changeset} -> raise "Failed to add member: #{inspect(changeset)}"
    end
  end

  def create_chat_message(attrs) do
    %ChatMessage{}
    |> ChatMessage.changeset(attrs)
    |> Repo.insert()
  end

  def list_messages(chattable_type, chattable_id, limit \\ 10) do
    chattable_id =
      if is_binary(chattable_id) do
        String.to_integer(chattable_id)
      else
        chattable_id
      end

    ChatMessage
    |> where([m], m.chattable_type == ^chattable_type and m.chattable_id == ^chattable_id)
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> limit(^limit)
    |> Repo.all()
  end
end
