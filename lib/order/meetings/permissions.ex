defmodule Order.Meetings.Permissions do
  import Ecto.Query
  alias Order.Meetings.Permission
  alias Order.Repo

  def get_permissions(%Order.Accounts.User{} = user, %Order.DB.Meeting{} = meeting) do
    scope = "id:#{meeting.id}"

    permissions =
      Repo.all(
        from p in Ecto.assoc(user, :permissions),
          where:
            p.resource == "meeting" and p.organization_id == ^meeting.organization_id and
              p.resource == "meeting" and (p.scope == "*" or p.scope == ^scope)
      )

    Enum.reduce(
      permissions,
      fn permission, acc ->
        Map.put(acc, permission.action, true)
      end,
      %{}
    )
    |> Permission.new()
  end
end
