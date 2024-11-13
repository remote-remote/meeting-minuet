defmodule Order.Memberships do
  import Ecto.Query
  alias Order.Tenures.Tenure
  alias Order.Positions.Position
  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Memberships.Membership
  alias Order.Accounts.User
  alias Order.Accounts

  # TODO: There is starting to be a good reason to move the Organizations
  # and Memberships contexts into Accounts
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

  def list_active_members(%Organization{} = organization, %Date{} = date) do
    Repo.all(
      from m in Membership,
        where:
          m.organization_id == ^organization.id and
            fragment("m0.active_range @> ?::date", ^date)
    )
  end

  def list_members(%Organization{} = organization) do
    Repo.all(
      from m in Membership,
        where: m.organization_id == ^organization.id
    )
    |> Repo.preload(:user)
    |> Repo.preload(:positions)
  end

  def get_membership(%Organization{} = organization, membership_id) do
    Repo.one(
      from m in Membership,
        join: t in Tenure,
        on: m.id == t.membership_id,
        join: u in User,
        on: m.user_id == u.id,
        join: p in Position,
        on: t.position_id == p.id,
        select: %{
          id: m.id,
          name: u.name,
          email: u.email,
          phone: u.phone,
          member_since: m.inserted_at
        },
        where: m.organization_id == ^organization.id and m.id == ^membership_id
    )
  end
end
