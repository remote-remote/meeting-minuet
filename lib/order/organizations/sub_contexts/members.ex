defmodule Order.Organizations.Members do
  import Ecto.Query
  import Order.DateHelper

  alias Order.Accounts.User
  alias Order.Organizations.{Member, Membership, Organization}
  alias Order.{Repo, Accounts}

  def invite_member(%Organization{} = organization, url_fn, attrs) do
    user =
      case Accounts.get_user_by_email(attrs["email"]) do
        nil -> Accounts.invite_user(attrs, url_fn)
        user -> user
      end

    attrs =
      Map.put(attrs, "user_id", user.id)
      |> Map.put("active_range", {Date.utc_today(), nil})

    %Membership{organization_id: organization.id}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  # list_members
  @spec list_members(%Organization{}) :: [%Member{}]
  def list_members(%Organization{} = organization) do
    list_members(organization.id)
  end

  @spec list_members(binary()) :: [%Member{}]
  def list_members(organization_id) when is_integer(organization_id) do
    Repo.all(
      from m in Membership,
        where: m.organization_id == ^organization_id
    )
    |> Repo.preload([:user, tenures: :position])
    |> Enum.map(fn m ->
      map_member(m, Date.utc_today())
    end)
  end

  # get_member
  @spec get_member!(%Organization{}, %User{}) :: %Member{}
  def get_member!(%Organization{} = organization, %User{} = user) do
    get_member!(organization.id, user.id)
  end

  @spec get_member!(%Organization{}, integer) :: %Member{}
  def get_member!(%Organization{} = organization, user_id) do
    get_member!(organization.id, user_id)
  end

  @spec get_member!(integer, integer) :: %Member{}
  def get_member!(organization_id, user_id)
      when (is_integer(organization_id) or is_binary(organization_id)) and
             (is_integer(user_id) or is_binary(user_id)) do
    Repo.one!(
      from m in Membership,
        where: m.organization_id == ^organization_id and m.user_id == ^user_id
    )
    |> Repo.preload([:user, tenures: :position])
    |> map_member(Date.utc_today())
  end

  # mapper
  defp map_member(%Membership{tenures: %Ecto.Association.NotLoaded{}} = m, %Date{} = date) do
    Repo.preload(m, [:user, tenures: :position]) |> map_member(date)
  end

  defp map_member(%Membership{user: %Ecto.Association.NotLoaded{}} = m, %Date{} = date) do
    Repo.preload(m, user: :tenures) |> map_member(date)
  end

  defp map_member(%Membership{} = m, %Date{} = date) do
    %Member{
      id: m.user_id,
      membership_id: m.id,
      name: m.user.name,
      email: m.user.email,
      phone: m.user.phone,
      active_range: m.active_range,
      roles: m.roles,
      current_positions:
        m.tenures
        |> Enum.filter(fn t ->
          in_range?(t.active_range, date)
        end)
        |> Enum.map(fn t ->
          %{
            position_id: t.position_id,
            tenure_id: t.id,
            name: t.position.name,
            description: t.position.description,
            active_range: t.active_range
          }
        end),
      past_positions:
        m.tenures
        |> Enum.reject(fn t ->
          in_range?(t.active_range, date)
        end)
        |> Enum.map(fn t ->
          %{
            position_id: t.position_id,
            tenure_id: t.id,
            name: t.position.name,
            description: t.position.description,
            active_range: t.active_range
          }
        end)
    }
  end
end
