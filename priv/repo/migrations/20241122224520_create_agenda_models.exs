defmodule MeetingMinuet.Repo.Migrations.CreateAgendaModels do
  use Ecto.Migration

  def change do
    create table(:agenda_items) do
      add :name, :string, null: false
      add :description, :string
      add :meeting_id, references(:meetings, on_delete: :delete_all), null: false
      add :status, :string, default: "scheduled"
      add :completed_at, :utc_datetime
      add :order, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:reports) do
      add :text, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:agenda_items_reports) do
      add :report_id, references(:reports, on_delete: :delete_all), null: false
      add :agenda_item_id, references(:agenda_items, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create table(:positions_reports) do
      add :position_id, references(:positions, on_delete: :delete_all), null: false
      add :report_id, references(:reports, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create table(:motions) do
      add :description, :string
      add :meeting_id, references(:meetings, on_delete: :delete_all), null: false
      add :motioned_by, references(:users, on_delete: :delete_all), null: false
      add :seconded_by, references(:users, on_delete: :delete_all), null: true
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create table(:reports_motions) do
      add :report_id, references(:reports, on_delete: :delete_all), null: false
      add :motion_id, references(:motions, on_delete: :delete_all), null: false
    end

    create table(:motion_votes) do
      add :motion_id, references(:motions, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :vote, :string, null: false
    end
  end
end
