defmodule Order.DB.Permission do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.DB.Organization
  alias Order.Repo

  schema "permissions" do
    field :resource, Ecto.Enum,
      values: [:meetings, :organization, :members, :positions, :permissions]

    field :scope, :string
    field :action, :string

    belongs_to :user, Order.Accounts.User
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(%Order.DB.Permission{} = permission, %{} = attrs) do
    permission
    |> cast(attrs, [:user_id, :organization_id, :resource, :scope, :action])
    |> validate_required([:user_id, :organization_id, :resource, :scope, :action])
  end

  def create(attrs) do
    %Order.DB.Permission{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(%{} = permission, attrs) do
    permission
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%{} = permission) do
    Repo.delete(permission)
  end
end
