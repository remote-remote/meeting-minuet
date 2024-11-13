defmodule Order.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Order.Accounts.User
  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Memberships.Membership

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%{}, ...]

  """
  def list_organizations(%User{} = user) do
    Repo.all(
      from [o, m] in user_organization_query(user),
        select: %Organization{
          id: o.id,
          name: o.name,
          description: o.description,
          inserted_at: o.inserted_at,
          updated_at: o.updated_at
        }
    )
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
      from [o, m] in user_organization_query(user),
        where: o.id == ^organization_id,
        select: o
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
  def create_organization(%User{} = user, attrs) do
    Ecto.build_assoc(user, :organizations)
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

  defp user_organization_query(%User{} = user) do
    from o in Organization,
      left_join: m in Membership,
      on: m.organization_id == o.id and m.user_id == ^user.id,
      where: (not is_nil(m.user_id) and m.user_id == ^user.id) or o.owner_id == ^user.id
  end
end
