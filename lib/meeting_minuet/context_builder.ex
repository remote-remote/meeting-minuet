defmodule MeetingMinuet.ContextBuilder do
  alias MeetingMinuet.Repo
  alias MeetingMinuet.Organizations.{Membership, Position, Tenure}

  def build_context(scenario) do
    %{}
    |> build_users(scenario)
    |> build_orgs(scenario)
  end

  def get_user(context, user_key) do
    context[:users][user_key]
  end

  def get_org(context, org_key) do
    context[:orgs][org_key][:org]
  end

  def get_position(context, org_key, position_key) do
    context[:orgs][org_key][:positions][position_key][:position]
  end

  def get_tenure(context, org_key, position_key, user_key) do
    context[:orgs][org_key][:positions][position_key][:tenures][user_key]
  end

  def get_membership(context, org_key, user_key) do
    context[:orgs][org_key][:memberships][user_key]
  end

  # private

  defp build_users(result, scenario) do
    Enum.reduce(scenario[:users], Map.put(result, :users, %{}), fn user, acc ->
      insert_user(acc, user)
    end)
  end

  defp build_orgs(result, scenario) do
    Enum.reduce(scenario[:orgs], Map.put(result, :orgs, %{}), fn org, acc ->
      insert_organization(acc, org) |> build_memberships(org) |> build_positions(org)
    end)
  end

  defp insert_organization(result, {org_key, org_config}) do
    org_name = org_config[:name] || Atom.to_string(org_key)

    {:ok, org} =
      MeetingMinuet.Organizations.create_organization(%{
        name: org_name,
        owner_id: result[:users][org_config[:owner]].id
      })

    put_in(result, [:orgs, org_key], %{
      org: org,
      positions: %{},
      memberships: %{}
    })
  end

  defp build_memberships(result, {org_key, org_config}) do
    Enum.reduce(org_config[:memberships] || %{}, result, fn membership, result ->
      insert_membership(result, org_key, membership)
    end)
  end

  defp build_positions(result, {org_key, org_config} = org) do
    Enum.reduce(
      org_config[:positions] || %{},
      result,
      fn position, result ->
        insert_position(result, org_key, position) |> build_tenures(org, position)
      end
    )
  end

  defp build_tenures(result, {org_key, _org_config}, {position_key, tenures}) do
    org_map = result[:orgs][org_key]
    position = org_map[:positions][position_key][:position]

    Enum.reduce(
      tenures,
      result,
      fn tenure, result ->
        insert_tenure(result, org_key, {position_key, position}, tenure)
      end
    )
  end

  defp insert_membership(result, org_key, {user_key, {lower, upper}}) do
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

  defp insert_position(result, org_key, {position_key, _config}) do
    position_string = Atom.to_string(position_key)
    org_map = result[:orgs][org_key]

    {:ok, position} =
      Repo.insert(%Position{
        organization_id: org_map[:org].id,
        name: position_string
      })

    put_in(result, [:orgs, org_key, :positions, position_key], %{position: position, tenures: %{}})
  end

  defp insert_user(result, {user_key, user_info}) do
    name = user_info[:name] || Atom.to_string(user_key)

    # we'll use the Accounts context for this one, since it will probably not change
    # and it requires a hashed password
    {:ok, user} =
      MeetingMinuet.Accounts.register_user(%{
        name: name,
        email: "#{String.downcase(name) |> String.replace(" ", "_")}@test.local",
        password: "password12345"
      })

    put_in(result, [:users, user_key], user)
  end

  defp insert_tenure(result, org_key, {position_key, position}, {user_key, {lower, upper}}) do
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
