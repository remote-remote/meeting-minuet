defmodule Order.Organizations.Permission do
  alias Order.Organizations.{Organization, Membership}
  alias Order.Accounts.User

  defmacro permission(name, roles) do
    quote do
      def unquote(:"#{name}?")(%Organization{memberships: memberships} = org, %User{} = user)
          when is_list(memberships) do
        case Enum.find(memberships, &(&1.user_id == user.id)) do
          nil -> false
          membership -> unquote(:"#{name}?")(org, membership)
        end
      end

      def unquote(:"#{name}?")(%Organization{} = org, %Membership{
            roles: member_roles,
            user_id: user_id
          }) do
        org.owner_id == user_id or Enum.any?(unquote(roles), &Enum.member?(member_roles, &1))
      end
    end
  end
end
