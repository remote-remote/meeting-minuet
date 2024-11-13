defmodule Order.OrgStructureBuilder do
  alias Order.Tenures.Tenure
  alias Order.Positions.Position
  alias Order.Repo
  alias Order.Memberships.Membership

  def build_org_scenario(scenario) do
    %{}
    |> build_users(scenario)
    |> build_orgs(scenario)
  end

  def build_users(result, scenario) do
    Enum.reduce(scenario[:users], Map.put(result, :users, %{}), fn {user_key, _}, acc ->
      insert_user(acc, user_key)
    end)
  end

  def build_orgs(result, scenario) do
    Enum.reduce(scenario[:orgs], Map.put(result, :orgs, %{}), fn org, acc ->
      insert_organization(acc, org) |> build_memberships(org) |> build_positions(org)
    end)
  end

  def insert_organization(result, {org_key, org_config}) do
    org_name = Atom.to_string(org_key)

    {:ok, org} =
      Order.Organizations.create_organization(%{
        name: org_name,
        owner_id: result[:users][org_config[:owner]].id
      })

    put_in(result, [:orgs, org_key], %{
      org: org,
      positions: %{},
      memberships: %{}
    })
  end

  def build_memberships(result, {org_key, org_config}) do
    Enum.reduce(org_config[:memberships] || %{}, result, fn membership, result ->
      insert_membership(result, org_key, membership)
    end)
  end

  def build_positions(result, {org_key, org_config} = org) do
    Enum.reduce(
      org_config[:positions] || %{},
      result,
      fn position, result ->
        insert_position(result, org_key, position) |> build_tenures(org, position)
      end
    )
  end

  def build_tenures(result, {org_key, org_config}, {position_key, _active_range}) do
    org_map = result[:orgs][org_key]
    position = org_map[:positions][position_key][:position]

    Enum.reduce(
      org_config[:memberships] || %{},
      result,
      fn membership, result ->
        insert_tenure(result, org_key, {position_key, position}, membership)
      end
    )
  end

  def insert_membership(result, org_key, {user_key, {lower, upper}}) do
    org_map = result[:orgs][org_key]
    user = result[:users][user_key]

    {:ok, membership} =
      Repo.insert(%Membership{
        organization_id: org_map[:org].id,
        user_id: user.id,
        active_range: %Postgrex.Range{
          lower: lower,
          upper: upper,
          lower_inclusive: true,
          upper_inclusive: true
        }
      })

    put_in(result, [:orgs, org_key, :memberships, user_key], membership)
  end

  def insert_position(result, org_key, {position_key, _config}) do
    position_string = Atom.to_string(position_key)
    org_map = result[:orgs][org_key]

    {:ok, position} =
      Repo.insert(%Position{
        organization_id: org_map[:org].id,
        name: position_string
      })

    put_in(result, [:orgs, org_key, :positions, position_key], %{position: position, tenures: %{}})
  end

  def insert_user(result, user_key) do
    user_string = Atom.to_string(user_key)

    # we'll use the Accounts context for this one, since it will probably not change
    # and it requires a hashed password
    {:ok, user} =
      Order.Accounts.register_user(%{
        name: user_string,
        email: "#{user_string}@test.local",
        password: "password12345"
      })

    put_in(result, [:users, user_key], user)
  end

  def insert_tenure(result, org_key, {position_key, position}, {user_key, {lower, upper}}) do
    org_map = result[:orgs][org_key]
    membership = org_map[:memberships][user_key]

    {:ok, tenure} =
      Repo.insert(%Tenure{
        membership_id: membership.id,
        position_id: position.id,
        active_range: %Postgrex.Range{
          lower: lower,
          upper: upper,
          lower_inclusive: true,
          upper_inclusive: true
        }
      })

    put_in(result, [:orgs, org_key, :positions, position_key, :tenures, user_key], tenure)
  end
end
