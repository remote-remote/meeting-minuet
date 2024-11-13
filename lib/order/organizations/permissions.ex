defmodule Order.Organizations.Permissions do
  import Ecto.Query
  alias Order.Repo
  alias Order.DB.Permission

  # def get_permissions(%Order.Accounts.User{} = user, %Order.DB.Organization{} = org) do
  #   scope = "id:#{org.id}"

  #   permissions =
  #     Repo.all(
  #       from p in Ecto.assoc(user, :permissions),
  #         where:
  #           p.resource == "organization" and p.organization_id == ^org.id and
  #             p.resource == "organization" and (p.scope == "*" or p.scope == ^scope)
  #     )

  #   wildcards = Enum.filter(permissions, &(&1.action == "*"))

  #   case wildcards do
  #     [] ->
  #       %{
  #         start_end: true,
  #         invite: true,
  #         view: true,
  #         edit: true
  #       }

  #     [_h | _t] ->
  #       %{
  #         start_end: permissions.includes?(%Permission{action: "start_end"}),
  #         invite: permissions.includes?(%Permission{action: "invite"}),
  #         view: permissions.includes?(%Permission{action: "view"}),
  #         edit: permissions.includes?(%Permission{action: "edit"})
  #       }
  #   end
  # end
end
