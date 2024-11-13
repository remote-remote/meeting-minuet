defmodule Order.Repo.Migrations.CreatePermissionsTable do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      add :resource, :string, null: false
      add :scope, :string, null: false
      add :action, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
