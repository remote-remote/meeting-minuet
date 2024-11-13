defmodule Order.Members do
  import Ecto.Query, warn: false
  alias Order.Repo
  alias Order.Accounts.User, warn: false
  alias Order.Organizations.Organization
  alias Order.Members.Member

  def add_member(%Organization{} = organization, attrs) do
    %Member{
      organization_id: organization.id
    }
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def list_active_members(%Organization{} = organization, %Date{} = date) do
    Repo.all(
      from m in Member,
        where: m.organization_id == ^organization.id and fragment("m0.period @> ?::date", ^date),
        select: %{
          id: m.id,
          name: m.name,
          email: m.email,
          phone: m.phone_number,
          member_since: m.inserted_at
        }
    )
  end

  def list_members(%Organization{} = organization) do
    Repo.all(
      from m in Member,
        where: m.organization_id == ^organization.id,
        select: %{
          id: m.id,
          name: m.name,
          email: m.email,
          phone: m.phone_number,
          member_since: m.inserted_at
        }
    )
  end
end
