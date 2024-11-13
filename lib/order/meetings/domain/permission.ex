defmodule Order.Meetings.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :start_end, :boolean, default: false
    field :invite, :boolean, default: false
    field :view, :boolean, default: false
    field :edit, :boolean, default: false
  end

  def changeset(%Order.Meetings.Permission{} = permission, attrs) do
    permission
    |> cast(attrs, [:start_end, :invite, :view, :edit])
  end

  def new(%{} = attrs) do
    %Order.Meetings.Permission{}
    |> changeset(attrs)
    |> apply_changes()
  end
end
