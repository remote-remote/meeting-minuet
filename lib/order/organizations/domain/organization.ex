defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :description, :string
    field :ami_owner, :boolean
    field :ami_member, :boolean

    embeds_many :members, Order.Organizations.Member
    embeds_many :meetings, Order.Organizations.Meeting
    embeds_many :positions, Order.Organizations.Position
    embeds_many :my_positions, Order.Organizations.Position
    embeds_one :permissions, Order.Organizations.Permission
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
