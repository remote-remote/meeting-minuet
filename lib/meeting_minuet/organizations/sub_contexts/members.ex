defmodule MeetingMinuet.Organizations.Members do
  import Ecto.Query
  alias MeetingMinuet.Accounts.User
  alias MeetingMinuet.Organizations.{Membership, Organization}
  alias MeetingMinuet.{Repo, Accounts}

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
  @spec list_members(%Organization{}) :: [%Membership{}]
  def list_members(%Organization{} = organization) do
    list_members(organization.id)
  end

  @spec list_members(integer()) :: [%Membership{}]
  def list_members(organization_id)
      when is_integer(organization_id) or is_binary(organization_id) do
    Repo.all(
      from m in Membership,
        where: m.organization_id == ^organization_id
    )
    |> Repo.preload([:user, tenures: :position])
  end

  # get_member
  def get_member!(membership_id) do
    Repo.get!(Membership, membership_id)
    |> Repo.preload([:user, tenures: :position])
  end

  @spec get_member!(%Organization{}, %User{}) :: %Membership{}
  def get_member!(%Organization{} = organization, %User{} = user) do
    get_member!(organization.id, user.id)
  end

  @spec get_member!(%Organization{}, integer) :: %Membership{}
  def get_member!(%Organization{} = organization, user_id) do
    get_member!(organization.id, user_id)
  end

  @spec get_member!(integer, integer) :: %Membership{}
  def get_member!(organization_id, user_id)
      when (is_integer(organization_id) or is_binary(organization_id)) and
             (is_integer(user_id) or is_binary(user_id)) do
    Repo.one!(
      from m in Membership,
        where: m.organization_id == ^organization_id and m.user_id == ^user_id
    )
    |> Repo.preload([:user, tenures: :position])
  end

  def get_membership(organization_id, user_id) do
    Repo.one(
      from m in Membership,
        where: m.organization_id == ^organization_id and m.user_id == ^user_id
    )
  end

  def is_member?(organization_id, user_id) do
    !is_nil(get_membership(organization_id, user_id))
  end
end
