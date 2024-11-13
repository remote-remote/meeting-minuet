defmodule Order.Meetings.PermissionsTest do
  use Order.DataCase

  import Order.AccountsFixtures
  import Order.MeetingsFixtures
  import Order.OrganizationsFixtures
  import Order.PermissionsFixtures

  alias Order.DB
  alias Order.Meetings.{Permissions, Permission}

  describe "get_permissions" do
    setup do
      user = user_fixture()
      org = organization_fixture(user.id)
      meeting = meeting_fixture(org.id)

      {:ok,
       %{
         user: user,
         org: org,
         meeting: meeting
       }}
    end

    test "returns all false if user has no permissions", %{
      user: user,
      org: org,
      meeting: meeting
    } do
      permissions = Permissions.get_permissions(user, meeting)
      assert permissions == %Permission{}
    end

    test "returns all true if user has wildcard permissions for meetings", %{
      user: user,
      org: org,
      meeting: meeting
    } do
      permission_fixture(%{
        user_id: user.id,
        organization_id: org.id,
        resource: :meetings,
        action: "*",
        scope: "*"
      })

      permissions = Permissions.get_permissions(user, meeting)
      assert permissions == %Permission{start_end: true, invite: true, view: true, edit: true}
    end

    test "returns true for all permissions if user has wildcard actions for this meeting", %{
      user: user,
      org: org,
      meeting: meeting
    } do
      permission_fixture(%{
        user_id: user.id,
        organization_id: org.id,
        resource: :meetings,
        action: "*",
        scope: "id:#{meeting.id}"
      })

      permissions = Permissions.get_permissions(user, meeting)
      assert permissions == %Permission{start_end: true, invite: true, view: true, edit: true}
    end

    test "returns true for specific permissions if user has specific actions for this meeting", %{
      user: user,
      org: org,
      meeting: meeting
    } do
      permission_fixture(%{
        user_id: user.id,
        organization_id: org.id,
        resource: :meetings,
        action: "start_end",
        scope: "id:#{meeting.id}"
      })

      permissions = Permissions.get_permissions(user, meeting)
      assert permissions == %Permission{start_end: true}
    end

    test "returns true for specific permissions if user has specific actions for all meetings", %{
      user: user,
      org: org,
      meeting: meeting
    } do
      permission_fixture(%{
        user_id: user.id,
        organization_id: org.id,
        resource: :meetings,
        action: "invite",
        scope: "*"
      })

      permissions = Permissions.get_permissions(user, meeting)
      assert permissions == %Permission{invite: true}
    end
  end
end
