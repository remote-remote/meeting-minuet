defmodule Order.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Order.Accounts.User
  alias Order.Repo

  alias Order.Organizations.Organization
  alias Order.Organizations.Membership
  alias Order.Organizations.Position
  alias Order.Organizations.OrganizationWithCurrentPosition

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%OrganizationWithCurrentPosition{}, ...]

  """
  def list_organizations(%User{} = user) do
    Repo.all(
      from [o, m, p] in user_organization_query(user),
        select: %OrganizationWithCurrentPosition{
          id: o.id,
          name: o.name,
          description: o.description,
          inserted_at: o.inserted_at,
          updated_at: o.updated_at,
          current_position: p.name
        }
    )
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(organization_id, %User{} = user) do
    Repo.one!(
      from [o, m, p] in user_organization_query(user),
        where: o.id == ^organization_id,
        select: o
    )
  end

  def list_positions(%Organization{} = organization) do
    Repo.all(
      from p in Position,
        left_join: m in Membership,
        on: m.position_id == p.id,
        left_join: u in User,
        on: u.id == m.user_id,
        where: p.organization_id == ^organization.id,
        select: %{
          id: p.id,
          title: p.name,
          member: %{
            id: u.id,
            first_name: u.first_name,
            last_name: u.last_name,
            email: u.email,
            phone_number: u.phone_number,
            since: m.inserted_at
          }
        }
    )
  end

  def create_position(%Organization{} = organization, attrs) do
    %Position{}
    |> Position.changeset(Map.put(attrs, "organization_id", organization.id))
    |> Repo.insert()
  end

  def add_member(%Organization{} = organization, %Position{} = position, %User{} = user) do
    %Membership{}
    |> Membership.changeset(%{
      organization_id: organization.id,
      position_id: position.id,
      user_id: user.id
    })
    |> Repo.insert()
  end

  def list_memberships(%Organization{} = organization) do
    Repo.all(
      from m in Membership,
        where: m.organization_id == ^organization.id,
        join: p in Position,
        on: p.id == m.position_id,
        join: u in User,
        on: u.id == m.user_id,
        select: %{position: p.name, email: u.email, member_since: m.inserted_at}
    )
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs, %User{id: owner_id}) do
    %Organization{}
    |> Organization.changeset(Map.put(attrs, "owner_id", owner_id))
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

  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end

  def update_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end

  defp user_organization_query(%User{id: user_id}) do
    from o in Organization,
      left_join: m in Membership,
      on: m.organization_id == o.id and m.user_id == ^user_id,
      left_join: p in Position,
      on: p.id == m.position_id,
      where: m.user_id == ^user_id or o.owner_id == ^user_id
  end
end
