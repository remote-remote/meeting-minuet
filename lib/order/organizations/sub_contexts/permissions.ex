defmodule Order.Organizations.Permissions do
  alias Order.Repo
  alias Order.DB
  alias Order.Organizations.{Permission}

  def get_permissions(
        %DB.Organization{memberships: %Ecto.Association.NotLoaded{}} = org,
        %Order.Accounts.User{} = user
      ) do
    get_permissions(Repo.preload(org, :memberships), user)
  end

  def get_permissions(%DB.Organization{} = org, %Order.Accounts.User{} = user) do
    membership = Enum.find(org.memberships, &(&1.user_id == user.id))
    get_permissions(org, membership)
  end

  def get_permissions(%DB.Organization{} = org, %DB.Membership{} = membership) do
    %Permission{
      edit_organization: edit_organization?(org, membership),
      delete_organization: delete_organization?(org, membership),
      create_meetings: create_meetings?(org, membership),
      delete_meetings: delete_meetings?(org, membership),
      edit_meetings: edit_meetings?(org, membership),
      add_members: add_members?(org, membership),
      delete_members: delete_members?(org, membership),
      add_positions: add_positions?(org, membership),
      assign_positions: assign_positions?(org, membership),
      edit_positions: edit_positions?(org, membership),
      delete_positions: delete_positions?(org, membership)
    }
  end

  defp edit_organization?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp delete_organization?(%DB.Organization{} = org, %DB.Membership{
         roles: roles,
         user_id: user_id
       }) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp create_meetings?(%DB.Organization{} = _org, %DB.Membership{
         roles: _roles,
         user_id: _user_id
       }) do
    true
  end

  defp delete_meetings?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp edit_meetings?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp add_members?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp delete_members?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp add_positions?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp assign_positions?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp edit_positions?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end

  defp delete_positions?(%DB.Organization{} = org, %DB.Membership{roles: roles, user_id: user_id}) do
    org.owner_id == user_id or Enum.member?(roles, :admin)
  end
end
