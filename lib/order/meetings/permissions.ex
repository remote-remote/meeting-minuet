defmodule Order.Meetings.Permissions do
  import Ecto.Query
  alias Order.Repo
  alias Order.Meetings.Permission

  def get_permissions(%Order.Accounts.User{} = user, %Order.DB.Meeting{} = meeting) do
    scope = "id:#{meeting.id}"

    actions =
      Repo.all(
        from p in Ecto.assoc(user, :permissions),
          where:
            p.resource == :meetings and p.organization_id == ^meeting.organization_id and
              (p.scope == "*" or p.scope == ^scope)
      )
      |> Enum.map(fn p -> p.action end)

    if "*" in actions do
      %Permission{start_end: true, invite: true, view: true, edit: true}
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
