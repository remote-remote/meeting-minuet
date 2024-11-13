defmodule Order.Positions.Position do
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :name, :string
    field :description, :string

    belongs_to :organization, Order.Organizations.Organization
    has_many :tenures, Order.Tenures.Tenure
    many_to_many :memberships, Order.Memberships.Membership, join_through: Order.Tenures.Tenure

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:name, :description, :organization_id])
    |> validate_required([:name, :organization_id])
  end
end
