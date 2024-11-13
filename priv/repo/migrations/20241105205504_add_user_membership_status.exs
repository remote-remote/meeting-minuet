defmodule Order.Repo.Migrations.AddUserMembershipStatus do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      add :status, :string, default: "invited"
    end

    alter table(:users) do
      add :status, :string, default: "invited"
    end
  end
end
