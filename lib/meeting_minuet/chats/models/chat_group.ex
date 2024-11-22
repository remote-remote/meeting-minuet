defmodule MeetingMinuet.Chats.ChatGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_groups" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name])
  end
end
