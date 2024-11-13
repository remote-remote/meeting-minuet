defmodule Order.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :name, :string
    field :email, :string
    field :phone, :string
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
    |> cast(attrs, [:name, :email, :phone, :active_range])
    |> validate_required([:name, :email, :active_range])
  end
end
