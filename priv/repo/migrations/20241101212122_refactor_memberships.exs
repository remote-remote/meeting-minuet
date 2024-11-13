defmodule Order.Repo.Migrations.RefactorMemberships do
  use Ecto.Migration

  def change do
    rename table(:members), to: table(:memberships)

    alter table(:users) do
      add :name, :string
      add :phone, :string
    end

    alter table(:memberships) do
      remove :email, :string
      remove :phone, :string
      remove :name, :string
    end

    rename table(:tenures), :member_id, to: :membership_id
  end
end
