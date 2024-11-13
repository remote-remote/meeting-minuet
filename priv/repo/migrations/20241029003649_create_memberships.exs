defmodule Order.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :position_id, references(:positions, on_delete: :nothing)
      add :period, :daterange

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:organization_id])
    create index(:memberships, [:user_id])
    create index(:memberships, [:position_id])
  end
end
