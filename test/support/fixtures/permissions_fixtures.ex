defmodule Order.PermissionsFixtures do
  alias Order.DB.Permission

  def permission_fixture(attrs \\ %{}) do
    attrs = valid_permission_attributes(attrs)

    %Permission{}
    |> Permission.changeset(attrs)
    |> Order.Repo.insert!()
  end

  def valid_permission_attributes(attrs) do
    Map.merge(%{resource: :meetings, action: "*", scope: "*"}, attrs)
  end
end
