defmodule MeetingMinuet.Repo.Migrations.CreateAgendaModels do
  use Ecto.Migration

  def change do
    create table(:agendas) do
      add :name, :string, null: false
      add :description, :string
      add :meeting_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:agenda_items) do
      add :name, :string, null: false
      add :description, :string
      add :agenda_id, references(:agendas, on_delete: :delete_all), null: false
      add :position_id, references(:positions, on_delete: :delete_all), null: true
      add :complete, :boolean, default: false
      add :completed_at, :utc_datetime

      timestamps()
    end

    create table(:motions) do
      add :description, :string
      add :motioned_by, references(:users, on_delete: :delete_all), null: false
      add :seconded_by, references(:users, on_delete: :delete_all), null: true
      add :status, :string, null: false, default: "pending"
      add :meeting_id, references(:meetings, on_delete: :delete_all), null: false
    end
  end
end
