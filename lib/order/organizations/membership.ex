defmodule Order.Organizations.Membership do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.Organizations.{Tenure, Organization}
  alias Order.Accounts.User

  schema "memberships" do
    field :active_range, EctoRange.Date

    belongs_to :user, User
    belongs_to :organization, Organization
    has_many :tenures, Tenure
    has_many :positions, through: [:tenures, :position]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :active_range])
    |> validate_required([:user_id, :active_range])
  end
end
