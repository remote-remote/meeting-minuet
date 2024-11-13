defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :description, :string
    field :owner_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :owner_id, :description])
    |> validate_required([:name, :owner_id])
  end
end
