defmodule Order.Organizations.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "organization_members" do
    field :id, :id
    field :user_id, :id
    field :membership_id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :active_range, EctoRange.Date

    embeds_many :current_positions, Order.Organization.MemberPosition
    embeds_many :past_positions, Order.Organization.MemberPosition
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:active_range])
    |> validate_required([:name, :organization_id])
  end
end

defmodule Order.Organizations.Member.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "member_position" do
    field :position_id, :id
    field :tenure_id, :id
    field :name, :string
    field :description, :string
    field :active_range, EctoRange.Date
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:name, :description, :active_range])
    |> validate_required([:name, :active_range])
  end
end
