defmodule Order.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :user_id, :id
    field :organization_id, :id
    field :active_range, EctoRange.Date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :email, :phone, :active_range])
    |> validate_required([:name, :email, :phone, :active_range])
  end
end
