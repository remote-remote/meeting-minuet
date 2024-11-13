defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :description, :string
    belongs_to :owner, Order.Accounts.User, foreign_key: :owner_id
    has_many :memberships, Order.Memberships.Membership
    has_many :meetings, Order.Meetings.Meeting
    has_many :positions, Order.Positions.Position
    many_to_many :users, Order.Accounts.User, join_through: Order.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :owner_id, :description])
    |> cast_assoc(:memberships)
    |> validate_required([:name, :owner_id])
  end
end
