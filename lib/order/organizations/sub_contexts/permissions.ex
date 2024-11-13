defmodule Order.Organizations.Permissions do
  alias Order.Repo
  alias Order.Organizations.{Permission, Organization, Membership}
  alias Order.Accounts.User

  def with_permissions(%Organization{} = org, %User{} = user) do
    permissions = get_permissions(org, user)
    Map.put(org, :permissions, permissions)
  end

  def get_permissions(
        %Organization{memberships: %Ecto.Association.NotLoaded{}} = org,
        %Order.Accounts.User{} = user
      ) do
    get_permissions(Repo.preload(org, :memberships), user)
  end

  def get_permissions(%Organization{} = org, %Order.Accounts.User{} = user) do
    membership = Enum.find(org.memberships, &(&1.user_id == user.id))
    get_permissions(org, membership)
  end

  def get_permissions(%Organization{} = org, %Membership{} = membership) do
    %Permission{
      edit_organization: edit_organization?(org, membership),
      delete_organization: delete_organization?(org, membership),
      create_meetings: create_meetings?(org, membership),
      delete_meetings: delete_meetings?(org, membership),
      edit_meetings: edit_meetings?(org, membership),
      add_members: add_members?(org, membership),
      delete_members: delete_members?(org, membership),
      create_positions: create_positions?(org, membership),
      assign_positions: assign_positions?(org, membership),
      edit_positions: edit_positions?(org, membership),
      delete_positions: delete_positions?(org, membership)
    }
  end

  def edit_organization?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def delete_organization?(%Organization{} = org, %Membership{
        roles: roles,
        user_id: user_id
      }) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def create_meetings?(%Organization{} = _org, %Membership{
        roles: _roles,
        user_id: _user_id
      }) do
    true
  end

  def delete_meetings?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def edit_meetings?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def add_members?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def delete_members?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def create_positions?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def assign_positions?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def edit_positions?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  def delete_positions?(%Organization{} = org, %Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end
end
