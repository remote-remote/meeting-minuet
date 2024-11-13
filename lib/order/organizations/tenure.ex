defmodule Order.Organizations.Tenure do
  use Ecto.Schema
  import Ecto.Changeset
  alias Order.Organizations.{Membership, Position}

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
    |> cast(attrs, [:active_range])
    |> validate_required([:active_range])
  end
end
