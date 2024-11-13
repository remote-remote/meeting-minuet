defmodule Order.Organizations.Organizations do
  alias Order.Accounts.User
  alias Order.Repo
  alias Order.DB
  alias Order.Organizations.Organization

  def list_organizations(%User{} = user) do
    DB.Organization.q_list_with_memberships(user.id)
    |> Repo.all()
    |> Enum.map(&Organization.from_db(&1, user))
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
    DB.Organization.q_get_with_memberships(user.id, organization_id)
    |> Repo.one!()
    |> Organization.from_db(user)
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
    member = %{
      "user_id" => user.id,
      "active_range" => {Date.utc_today(), nil}
    }

    attrs = Map.put(attrs, "memberships", [member])

    case Ecto.build_assoc(user, :owned_organizations)
         |> DB.Organization.changeset(attrs)
         |> Repo.insert() do
      {:ok, organization} -> {:ok, Organization.from_db(organization, user)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_organization(attrs) do
    %Organization{}
    |> DB.Organization.changeset(attrs)
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
    |> Organization.to_db()
    |> DB.Organization.changeset(attrs)
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
    Repo.delete(%DB.Organization{id: organization.id})
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
