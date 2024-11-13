defmodule Order.Repo.Migrations.CreateAttendees do
  use Ecto.Migration

  def change do
    create table(:attendees) do
      add :status, :string
      add :meeting_id, references(:meetings, on_delete: :restrict)
      add :membership_id, references(:members, on_delete: :restrict)
      add :rsvp_date, :utc_datetime
      add :marked_present_at, :utc_datetime
      add :in_person, :boolean
      add :online, :boolean

      timestamps(type: :utc_datetime)
    end

    create index(:attendees, [:meeting_id])
    create index(:attendees, [:membership_id])
  end
end
