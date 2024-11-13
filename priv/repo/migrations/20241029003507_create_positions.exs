defmodule Order.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :name, :string
      add :description, :string
      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:positions, [:organization_id])
  end
end
