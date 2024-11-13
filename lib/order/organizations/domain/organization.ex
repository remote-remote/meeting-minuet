defmodule Order.Organizations.Organization do
  import Ecto.Changeset
  alias Order.{Organizations, Accounts, DB}

  use Ecto.Schema
  use Order.DomainModel, db_module: Order.DB.Organization

  embedded_schema do
    field :name, :string
    field :description, :string
    field :owner_id, :id

    embeds_one :permissions, Order.Organizations.Permission
  end

  @doc false
  def changeset(%Organizations.Organization{} = organization, attrs) do
    organization
    |> to_db()
    |> changeset(attrs)
  end

  def changeset(%DB.Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name, :description, :owner_id])
    |> validate_required([:name, :owner_id])
  end

  def from_db(%DB.Organization{} = org, %Accounts.User{} = user) do
    org =
      case org do
        %Order.DB.Organization{memberships: %Ecto.Association.NotLoaded{}} ->
          Order.Repo.preload(org, :memberships)

        _ ->
          org
      end

    %Organizations.Organization{
      id: org.id,
      name: org.name,
      description: org.description,
      owner_id: org.owner_id,
      permissions: Organizations.Permissions.get_permissions(org, user)
    }
  end

  def to_db(%Organizations.Organization{} = org) do
    %DB.Organization{
      id: org.id,
      name: org.name,
      description: org.description,
      owner_id: org.owner_id
    }
  end
end
