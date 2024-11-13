defmodule Order.Repo.Migrations.CreateTenures do
  use Ecto.Migration

  def change do
    create table(:tenures) do
      add :active_range, :daterange
      add :member_id, references(:members, on_delete: :nothing)
      add :position_id, references(:positions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tenures, [:member_id])
    create index(:tenures, [:position_id])
  end
end
