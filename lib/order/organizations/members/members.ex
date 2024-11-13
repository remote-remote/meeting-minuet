defmodule Order.Organizations.Members do
  import Ecto.Query
  import Order.DateHelper

  alias Order.Organizations.{Membership, Organization, Member}
  alias Order.{Repo, Accounts}

  def add_member(%Organization{} = organization, attrs) do
    user =
      case Accounts.get_user_by_email(attrs["email"]) do
        nil -> Accounts.invite_user(attrs)
        user -> user
      end

    attrs = Map.put(attrs, "user_id", user.id)

    Ecto.build_assoc(organization, :memberships)
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  @spec list_members(%Organization{}) :: [%Member{}]
  def list_members(%Organization{} = organization) do
    list_members(organization.id)
  end

  @spec list_members(binary) :: [%Member{}]
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

  @spec get_member!(%Organization{}, integer) :: %Member{}
  def get_member!(%Organization{} = organization, membership_id) when is_integer(membership_id) do
    get_member!(organization.id, membership_id)
  end

  @spec get_member!(integer, integer) :: %Member{}
  def get_member!(organization_id, membership_id)
      when is_integer(organization_id) and is_integer(membership_id) do
    Repo.one!(
      from m in Membership,
        where: m.organization_id == ^organization_id and m.id == ^membership_id
    )
    |> Repo.preload([:user, tenures: :position])
    |> map_member(Date.utc_today())
  end

  defp map_member(%Membership{} = m, %Date{} = date) do
    %Member{
      id: m.id,
      user_id: m.user_id,
      name: m.user.name,
      email: m.user.email,
      phone: m.user.phone,
      active_range: m.active_range,
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
