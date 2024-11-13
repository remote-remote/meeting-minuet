defmodule Order.Repo.Migrations.ChangeMeetingSchedules do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :date, :date
      add :scheduled_start_time, :time
      add :scheduled_end_time, :time
      add :running_start_time, :time
      add :running_end_time, :time
      add :timezone, :string
      add :location, :string

      remove :running_time, :tstzrange
      remove :scheduled_time, :tstzrange
    end
  end
end
