defmodule Order.Organizations.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :edit_organization, :boolean, default: false
    field :delete_organization, :boolean, default: false

    field :create_meetings, :boolean, default: false
    field :delete_meetings, :boolean, default: false
    field :edit_meetings, :boolean, default: false

    field :add_members, :boolean, default: false
    field :delete_members, :boolean, default: false

    field :add_positions, :boolean, default: false
    field :assign_positions, :boolean, default: false
    field :edit_positions, :boolean, default: false
    field :delete_positions, :boolean, default: false
  end

  def changeset(%Order.Organizations.Permission{} = permission, attrs \\ %{}) do
    permission
    |> cast(attrs, [
      :edit_organization,
      :create_meetings,
      :delete_meetings,
      :edit_meetings,
      :add_members,
      :delete_members,
      :add_positions,
      :assign_positions,
      :edit_positions,
      :delete_positions
    ])
  end

  def new(%{} = attrs) do
    %Order.Organizations.Permission{}
    |> changeset(attrs)
    |> apply_changes()
  end
end
