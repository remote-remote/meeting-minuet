defmodule MeetingMinuet.Chats.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    belongs_to :user, MeetingMinuet.Accounts.User

    field :body, :string, default: ""
    field :chattable_type, Ecto.Enum, values: [:group, :meeting, :organization]
    field :chattable_id, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:user_id, :chattable_type, :chattable_id, :body])
    |> validate_required([:user_id, :chattable_type, :chattable_id, :body])
  end
end
