defmodule Order.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :description, :string
      add :owner_id, references(:users, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end
  end
end
