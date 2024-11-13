defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Order.Organizations.{Organization, Membership, Position}
  alias Order.Meetings.Meeting
  alias Order.Accounts.User

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

  @doc """
  Returns the organization with the given id.
  """
  @spec q_list_with_memberships(integer()) :: Ecto.Query.t()
  def q_list_with_memberships(user_id) do
    from o in Organization,
      left_join: m in assoc(o, :memberships),
      on: m.user_id == ^user_id,
      where: not is_nil(m.id) or o.owner_id == ^user_id,
      preload: [:memberships]
  end

  def q_get_with_memberships(user_id, org_id) do
    q_list_with_memberships(user_id)
    |> where([o], o.id == ^org_id)
  end
end
