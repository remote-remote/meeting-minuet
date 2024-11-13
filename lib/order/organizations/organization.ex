defmodule Order.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :description, :string
    belongs_to :owner, Order.Accounts.User, foreign_key: :owner_id
    has_many :members, Order.Members.Member
    has_many :meetings, Order.Meetings.Meeting
    has_many :positions, Order.Positions.Position
    # has_many :tenures, through: [:positions, :members]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :owner_id, :description])
    |> validate_required([:name, :owner_id])
  end
end
