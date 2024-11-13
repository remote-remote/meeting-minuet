defmodule Order.DB.Position do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
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
  def changeset(position, attrs \\ %{}) do
    position
    |> cast(attrs, [:name, :description, :organization_id, :requires_report])
    |> validate_required([:name, :organization_id])
  end

  def q_list_with_tenures(org_id) do
    from p in Order.DB.Position,
      preload: [tenures: :user],
      where: p.organization_id == ^org_id
  end

  def q_get_with_tenures(position_id) do
    from p in Order.DB.Position,
      preload: [tenures: :user],
      where: p.id == ^position_id
  end

  def q_get_with_tenures(org_id, position_id) do
    q_list_with_tenures(org_id)
    |> where([p], p.id == ^position_id)
  end
end
