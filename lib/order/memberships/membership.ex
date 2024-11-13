defmodule Order.Memberships.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :active_range, EctoRange.Date

    belongs_to :user, Order.Accounts.User
    belongs_to :organization, Order.Organizations.Organization
    has_many :tenures, Order.Tenures.Tenure
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
