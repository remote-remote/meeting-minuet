defmodule Order.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Order.Accounts.User
  alias Order.Repo
  alias Order.DB.{Organization}

  # Members
  defdelegate list_members(organization), to: Order.Organizations.Members
  defdelegate get_member!(organization, membership_id), to: Order.Organizations.Members
  defdelegate invite_member(organization, url_fn, attrs), to: Order.Organizations.Members

  # Positions
  defdelegate list_positions(organization), to: Order.Organizations.Positions
  defdelegate get_position!(organization, position_id), to: Order.Organizations.Positions
  defdelegate create_position(organization, attrs), to: Order.Organizations.Positions
  defdelegate change_position(position, attrs \\ %{}), to: Order.Organizations.Positions
  defdelegate update_position(position, attrs), to: Order.Organizations.Positions

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
end
