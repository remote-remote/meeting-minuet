defmodule Order.Organizations.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :invite, :boolean, default: false
    field :edit, :boolean, default: false
    field :view, :boolean, default: false
    field :delete, :boolean, default: false
  end

  def changeset(%Order.Organizations.Permission{} = permission, attrs) do
    permission
    |> cast(attrs, [:invite, :view, :edit, :delete])
  end

  def new(%{} = attrs) do
    %Order.Organizations.Permission{}
    |> changeset(attrs)
    |> apply_changes()
  end
end
