defmodule MeetingMinuet.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :user_id, references(:users, on_delete: :restrict)
      add :organization_id, references(:organizations, on_delete: :restrict)
      add :active_range, :daterange

      timestamps(type: :utc_datetime)
    end

    create index(:members, [:organization_id])
    create index(:members, [:user_id])
  end
end
