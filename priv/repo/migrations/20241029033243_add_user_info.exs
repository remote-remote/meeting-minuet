defmodule Order.Repo.Migrations.AddUserInfo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string
    end

    alter table(:organizations) do
      add :owner_id, references(:users, on_delete: :delete_all)
    end
  end
end
