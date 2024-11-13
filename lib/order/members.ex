defmodule Order.Members do
  import Ecto.Query
  alias Order.Tenures.Tenure
  alias Order.Positions.Position
  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Members.Member

  def add_member(%Organization{} = organization, attrs) do
    Ecto.build_assoc(organization, :members)
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def list_active_members(%Organization{} = organization, %Date{} = date) do
    Repo.all(
      from m in Member,
        where: m.organization_id == ^organization.id and fragment("m0.period @> ?::date", ^date)
    )
  end

  def list_members(%Organization{} = organization) do
    Repo.all(
      from m in Member,
        where: m.organization_id == ^organization.id
    )
  end

  def get_member(%Organization{} = organization, member_id) do
    Repo.one(
      from m in Member,
        join: t in Tenure,
        on: m.id == t.member_id,
        join: p in Position,
        on: t.position_id == p.id,
        select: %{
          id: m.id,
          name: m.name,
          email: m.email,
          phone: m.phone,
          member_since: m.inserted_at
        },
        where: m.organization_id == ^organization.id and m.id == ^member_id
    )
  end
end
