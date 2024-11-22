defmodule MeetingMinuet.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :title, :string
      add :status, :string
      add :topic, :string
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :date, :date
      add :scheduled_start_time, :time
      add :scheduled_end_time, :time
      add :running_start_time, :time
      add :running_end_time, :time
      add :timezone, :string
      add :location, :string

      timestamps(type: :utc_datetime)
    end

    create index(:meetings, [:organization_id])
  end
end
