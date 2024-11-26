defmodule MeetingMinuetWeb.DTO.MemberInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :email, :string
    field :name, :string
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end

  def validate(invitation) do
    invitation
    |> validate_format(:email, ~r/@/)
    |> validate_required([:name])
  end
end
