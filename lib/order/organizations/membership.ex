defmodule Order.Organizations.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :organization_id, :id
    field :user_id, :id
    field :position_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id, :position_id])
    |> validate_required([:organization_id, :user_id, :position_id])
  end
end
