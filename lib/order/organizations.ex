defmodule Order.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Order.Accounts.User
  alias Order.Repo
  alias Order.Organizations.{Organization, Position}

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

  # Positions

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
end
