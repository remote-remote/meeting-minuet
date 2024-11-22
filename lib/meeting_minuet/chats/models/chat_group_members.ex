defmodule MeetingMinuet.Chats.ChatGroupMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_group_members" do
    belongs_to :user, MeetingMinuet.Accounts.User
    belongs_to :chat_group, MeetingMinuet.Chats.ChatGroup

    timestamps(type: :utc_datetime)
  end

  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, [:user_id, :chat_id])
    |> validate_required([:user_id, :chat_id])
  end
end
