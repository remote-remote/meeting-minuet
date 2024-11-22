defmodule MeetingMinuet.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:chat_groups) do
      add :name, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create table(:chat_group_members) do
      add :chat_id, references(:chat_groups, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create table(:chat_messages) do
      add :user_id, references(:users, on_delete: :delete_all), null: false

      add :chattable_type, :string, null: false
      add :chattable_id, :integer, null: false

      add :body, :string, default: ""

      timestamps(type: :utc_datetime)
    end
  end
end
