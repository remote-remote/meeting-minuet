defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.Organizations.{Membership, Position}
  alias Order.Accounts.User
  alias Order.Meetings.Meeting

  schema "organizations" do
    field :name, :string
    field :description, :string
    belongs_to :owner, User, foreign_key: :owner_id
    has_many :memberships, Membership
    has_many :meetings, Meeting
    has_many :positions, Position
    many_to_many :users, User, join_through: Membership

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
