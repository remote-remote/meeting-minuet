defmodule MeetingMinuet.Organizations.Tenure do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias MeetingMinuet.Organizations.{Membership, Position}

  schema "tenures" do
    field :active_range, EctoRange.Date

    belongs_to :membership, Membership
    belongs_to :position, Position

    has_one :user, through: [:membership, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tenure, attrs) do
    tenure
    |> cast(attrs, [:active_range, :position_id, :membership_id])
    |> validate_required([:active_range, :position_id, :membership_id])
  end

  def q_get(org_id, tenure_id) do
    from t in __MODULE__,
      join: p in Position,
      on: p.id == t.position_id,
      where: t.id == ^tenure_id and p.organization_id == ^org_id
  end
end
