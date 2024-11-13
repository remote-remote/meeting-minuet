defmodule Order.Tenures.Tenure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenures" do
    field :active_range, EctoRange.Date

    belongs_to :member, Order.Members.Member
    belongs_to :position, Order.Positions.Position

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tenure, attrs) do
    tenure
    |> cast(attrs, [:active_range])
    |> validate_required([:active_range])
  end
end
