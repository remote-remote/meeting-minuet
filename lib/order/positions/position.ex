defmodule Order.Positions.Position do
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :name, :string
    field :description, :string
    field :organization_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:name, :description, :organization_id])
    |> validate_required([:name, :organization_id])
  end
end
