defmodule Order.Organizations.Membership do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.Organizations.{Tenure, Organization}
  alias Order.Accounts.User

  schema "memberships" do
    field :active_range, EctoRange.Date
    field :status, Ecto.Enum, values: [:invited, :active, :revoked], default: :invited
    field :roles, {:array, Ecto.Enum}, values: [:member, :admin], default: [:member]

    belongs_to :user, User
    belongs_to :organization, Organization
    has_many :tenures, Tenure
    has_many :positions, through: [:tenures, :position]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :active_range, :roles])
    |> validate_required([:user_id, :active_range, :roles])
  end
end
