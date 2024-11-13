defmodule Order.DB.Position do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.DB.{Membership, Tenure, Organization}

  schema "positions" do
    field :name, :string
    field :description, :string
    field :requires_report, :boolean, default: false

    belongs_to :organization, Organization
    has_many :tenures, Tenure
    many_to_many :memberships, Membership, join_through: Tenure

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:name, :description, :organization_id])
    |> validate_required([:name, :organization_id])
  end
end
