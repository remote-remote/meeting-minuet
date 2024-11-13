defmodule OrderWeb.Dtos.MemberInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "member_invitations" do
    field :email, :string
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
