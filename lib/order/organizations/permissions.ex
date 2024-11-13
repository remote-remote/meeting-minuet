defmodule Order.Organizations.Permissions do
  import Ecto.Query
  alias Order.Repo
  alias Order.Organizations.Permission

  def get_permissions(%Order.Accounts.User{} = user, %Order.DB.Organization{} = org) do
    scope = "id:#{org.id}"

    actions =
      Repo.all(
        from p in Ecto.assoc(user, :permissions),
          where:
            p.resource == :organization and p.organization_id == ^org.id and
              (p.scope == "*" or p.scope == ^scope)
      )
      |> Enum.map(fn p -> p.action end)

    if "*" in actions do
      %Permission{invite: true, view: true, edit: true, delete: true}
    else
      Enum.reduce(
        actions,
        %{},
        fn action, acc ->
          Map.put(acc, action, true)
        end
      )
      |> Permission.new()
    end
  end
end
