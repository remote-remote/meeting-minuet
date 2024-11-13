defmodule Order.ContextBuilderTest do
  use Order.DataCase
  import Order.ContextBuilder
  import Order.Repo
  alias Order.Accounts.User
  alias Order.Organizations.Organization
  alias Order.Positions.Position
  alias Order.Memberships.Membership
  alias Order.Tenures.Tenure

  @input %{
    # username: %{ ??? future config }
    users: %{
      user1: %{},
      user2: %{},
      user3: %{},
      user4: %{}
    },
    orgs: %{
      # orgname: %{ owner, memberships, positions }
      org1: %{
        # key of users
        owner: :user1,
        memberships: %{
          # username: active_range
          user1: {nil, nil},
          user2: {nil, nil}
        },
        positions: %{
          chair: %{
            # keyof member and users: active_range
            user1: {Date.new!(2023, 1, 1), 2023, 12, 31},
            user2: {Date.new!(2024, 1, 1), nil}
          },
          fluffer: %{},
          janitor: %{}
        }
      },
      org2: %{
        owner: :user1,
        positions: %{}
      }
    }
  }

  describe "organizations" do
    setup do
      structure =
        build_context(@input)

      {:ok, structure}
    end

    test "has the keys", structure do
      # general structure
      assert Map.has_key?(structure, :users)
      assert Map.has_key?(structure, :orgs)
      assert Map.has_key?(structure[:orgs], :org1)
      assert Map.has_key?(structure[:orgs], :org2)
      assert Map.has_key?(structure[:orgs][:org1], :org)
      assert Map.has_key?(structure[:orgs][:org1], :positions)
      assert Map.has_key?(structure[:orgs][:org1], :memberships)
      assert Map.has_key?(structure[:orgs][:org1][:positions], :chair)
      assert Map.has_key?(structure[:orgs][:org1][:positions], :fluffer)
      assert Map.has_key?(structure[:orgs][:org1][:positions], :janitor)
      assert Map.has_key?(structure[:orgs][:org1][:memberships], :user1)
      assert Map.has_key?(structure[:orgs][:org1][:memberships], :user2)
      assert Map.has_key?(structure[:users], :user1)
      assert Map.has_key?(structure[:users], :user2)
      assert Map.has_key?(structure[:users], :user3)
      assert Map.has_key?(structure[:users], :user4)
    end

    test "orgs were saved", structure do
      assert Map.size(@input[:orgs]) == Repo.aggregate(Organization, :count, :id)
      user1 = Repo.get_by!(User, name: "user1")
      org1 = Repo.get_by!(Organization, name: "org1")
      org2 = Repo.get_by!(Organization, name: "org2")
      assert structure[:orgs][:org1][:org].id == org1.id
      assert structure[:orgs][:org2][:org].id == org2.id
      assert structure[:users][:user1].id == org1.owner_id
      assert structure[:users][:user1].id == org2.owner_id
      assert user1.id == org1.owner_id
      assert user1.id == org2.owner_id
    end

    test "users were saved", structure do
      assert Map.size(@input[:users]) == Repo.aggregate(User, :count, :id)
      user1 = Repo.get_by!(User, name: "user1")
      user2 = Repo.get_by!(User, name: "user2")
      user3 = Repo.get_by!(User, name: "user3")
      user4 = Repo.get_by!(User, name: "user4")
      assert structure[:users][:user1].id == user1.id
      assert structure[:users][:user2].id == user2.id
      assert structure[:users][:user3].id == user3.id
      assert structure[:users][:user4].id == user4.id
    end

    test "positions were saved", structure do
      assert Repo.aggregate(Position, :count, :id) == 3
      assert org1 = Repo.get_by!(Organization, name: "org1")
      assert chair = Repo.get_by!(Position, name: "chair", organization_id: org1.id)
      assert fluffer = Repo.get_by!(Position, name: "fluffer", organization_id: org1.id)
      assert janitor = Repo.get_by!(Position, name: "janitor", organization_id: org1.id)
      assert structure.orgs.org1.positions.chair.position.id == chair.id
      assert structure.orgs.org1.positions.fluffer.position.id == fluffer.id
      assert structure.orgs.org1.positions.janitor.position.id == janitor.id
    end

    test "memberships were saved", structure do
      assert Repo.aggregate(Membership, :count, :id) == 2
      org1 = structure.orgs.org1.org

      saved =
        Repo.all(
          from m in Membership, where: m.organization_id == ^org1.id, order_by: [asc: m.id]
        )
        |> Enum.map(&Map.drop(&1, [:active_range]))

      from_structure =
        Map.values(structure.orgs.org1.memberships)
        |> Enum.map(&Map.drop(&1, [:active_range]))

      assert saved == from_structure
    end
  end
end
