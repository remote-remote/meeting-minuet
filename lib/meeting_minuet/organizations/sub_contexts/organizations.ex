defmodule MeetingMinuet.Organizations.Organizations do
  alias MeetingMinuet.Repo
  alias MeetingMinuet.Accounts.User
  alias MeetingMinuet.Organizations.Organization
  import Ecto.Query

  def list_organizations(%User{} = user) do
    Organization.q_list_with_memberships(user.id)
    |> Repo.all()
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
  @spec get_organization!(%User{}, integer()) :: %Organization{}
  def get_organization!(%User{} = user, organization_id) do
    Organization.q_get_with_memberships(user.id, organization_id)
    |> Repo.one!()
  end

  def get_fully_preloaded_organization!(%User{} = user, org_id) do
    Organization.q_get_with_everything(user.id, org_id)
    |> Repo.one!()
  end

  def get_organization!(organization_id) do
    Repo.one!(
      from o in Organization,
        where: o.id == ^organization_id,
        preload: [:memberships]
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
  def create_organization(attrs, %User{} = user) do
    member = %{
      "user_id" => user.id,
      "active_range" => {Date.utc_today(), nil}
    }

    attrs = Map.put(attrs, "memberships", [member])

    case Ecto.build_assoc(user, :owned_organizations)
         |> Organization.changeset(attrs)
         |> Repo.insert() do
      {:ok, organization} -> {:ok, organization}
      {:error, changeset} -> {:error, changeset}
    end
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
