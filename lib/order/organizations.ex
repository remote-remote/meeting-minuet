defmodule Order.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Order.Accounts.User
  alias Order.Accounts
  alias Order.Repo
  alias Order.Organizations.{Organization, Position, Membership, Tenure}

  @doc """
  Returns a list of organizations that the user owns via organization.owner_id.
  """
  def owned_organizations(%User{} = user) do
    Ecto.assoc(user, :owned_organizations) |> Repo.all()
  end

  @doc """
  Returns a list of organizations that the user is a member of.
  """
  def member_organizations(%User{} = user) do
    Ecto.assoc(user, :member_organizations) |> Repo.all()
  end

  @doc """
  Gets a single organization if it belongs to the User.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(%User{id: 1}, 123)
      %Organization{}

      iex> get_organization!(%User{id:1}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(%User{} = user, organization_id) do
    Repo.one!(
      from o in Organization,
        where: o.id == ^organization_id,
        left_join: m in assoc(o, :memberships),
        where: m.user_id == ^user.id or o.owner_id == ^user.id,
        distinct: true
    )
  end

  def get_organization!(organization_id) do
    Repo.get!(Organization, organization_id)
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs, %User{} = user) do
    member = %{"user_id" => user.id, "active_range" => {Date.utc_today(), nil}}
    attrs = Map.put(attrs, "memberships", [member])

    Ecto.build_assoc(user, :owned_organizations)
    |> Organization.changeset(attrs)
    |> Repo.insert()
    |> IO.inspect(label: "create_organization for user")
  end

  def create_organization(attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  ## Memberships
  def add_membership(%Organization{} = organization, attrs) do
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

  def in_range?(range, date) do
    gte_lower =
      if is_nil(range.lower) || range.lower == :unbound do
        true
      else
        comp = Date.compare(date, range.lower)
        comp == :gt or comp == :eq
      end

    lte_upper =
      if is_nil(range.upper) or range.upper == :unbound do
        true
      else
        comp = Date.compare(date, range.upper)
        comp == :lt or comp == :eq
      end

    gte_lower and lte_upper
  end

  @spec list_members(%Organization{}) :: [%Order.Organizations.Member{}]
  def list_members(%Organization{} = organization) do
    list_members(organization.id)
  end

  @spec list_members(binary) :: [%Order.Organizations.Member{}]
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

  @spec get_member!(%Organization{}, integer) :: %Order.Organizations.Member{}
  def get_member!(%Organization{} = organization, membership_id) when is_integer(membership_id) do
    get_member!(organization.id, membership_id)
  end

  @spec get_member!(integer, integer) :: %Order.Organizations.Member{}
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
    %Order.Organizations.Member{
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

  @doc """
  Returns a Position changeset
  """
  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end

  def update_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end

  def list_positions(%Organization{} = organization) do
    Repo.all(
      from p in Ecto.assoc(organization, :positions),
        left_join: t in assoc(p, :tenures),
        on: fragment("t1.active_range @> ?::date", ^Date.utc_today()),
        left_join: m in assoc(t, :membership),
        left_join: u in assoc(m, :user),
        select: %{
          id: p.id,
          name: p.name,
          description: p.description,
          user: %{
            id: u.id,
            name: u.name,
            email: u.email,
            phone: u.phone
          }
        }
    )
  end

  def get_position!(%Organization{} = organization, position_id) do
    Repo.one!(
      from p in Position,
        where: p.organization_id == ^organization.id and p.id == ^position_id
    )
  end

  def get_position!(position_id) do
    Repo.get(Position, position_id)
  end

  def create_position(%Organization{} = organization, attrs) do
    Ecto.build_assoc(organization, :positions)
    |> Position.changeset(attrs)
    |> Repo.insert()
  end

  def list_tenures(%User{} = user) do
    Repo.all(
      from t in Tenure,
        join: m in Membership,
        on: t.membership_id == m.id,
        join: p in Position,
        on: t.position_id == p.id,
        join: o in Organization,
        on: p.organization_id == o.id,
        where: m.user_id == ^user.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            first_name: m.first_name,
            last_name: m.last_name
          },
          position: %{
            id: p.id,
            title: p.name
          },
          organization: %{
            id: o.id,
            name: o.name
          }
        }
    )
  end

  def list_tenures(%Membership{} = membership) do
    Repo.all(
      from t in Tenure,
        join: p in Position,
        on: t.position_id == p.id,
        join: o in Organization,
        on: p.organization_id == o.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          organization: %{
            id: o.id,
            name: o.name
          },
          position: %{
            id: p.id,
            name: p.name
          }
        },
        where: t.membership_id == ^membership.id
    )
  end

  def list_tenures(%Position{} = position) do
    Repo.all(
      from t in Tenure,
        join: m in Membership,
        on: t.membership_id == m.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            name: m.name,
            email: m.email
          }
        },
        where: t.position_id == ^position.id
    )
  end

  def list_tenures(%Organization{} = organization) do
    Repo.all(
      from t in Tenure,
        join: p in Position,
        on: t.position_id == p.id,
        join: m in Membership,
        on: t.membership_id == m.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            name: m.name,
            email: m.email
          },
          position: %{
            id: p.id,
            name: p.name
          }
        },
        where: p.organization_id == ^organization.id
    )
  end

  def create_tenure(%Membership{id: membership_id}, %Position{id: position_id}, attrs \\ %{}) do
    # TODO: build_assoc from member to positon and vice versa?
    %Tenure{
      position_id: position_id,
      membership_id: membership_id
    }
    |> Tenure.changeset(attrs)
    |> Repo.insert()
  end
end
