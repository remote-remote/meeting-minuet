defmodule Order.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :name, :string
      add :description, :string
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :requires_report, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:positions, [:organization_id])
  end
end
