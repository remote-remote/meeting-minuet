defmodule Order.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :title, :string
      add :status, :string
      add :topic, :string
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :running_time, :tstzrange
      add :scheduled_time, :tstzrange

      timestamps(type: :utc_datetime)
    end

    create index(:meetings, [:organization_id])
  end
end
