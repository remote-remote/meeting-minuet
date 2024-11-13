defmodule Order.Repo.Migrations.AddPermission do
  use Ecto.Migration

  # << organization ud, memberships crud, attendees crud, position crud >>  
  def change do
    alter table(:memberships) do
      add :roles, {:array, :string}, default: ["member"]
    end

    alter table(:users) do
      add :roles, {:array, :string}, default: ["user"]
    end

    alter table(:attendees) do
      add :roles, {:array, :string}, default: ["attendee"]
    end
  end
end
