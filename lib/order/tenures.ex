defmodule Order.Tenures do
  import Ecto.Query, warn: false
  alias Order.Repo

  alias Order.Accounts.User
  alias Order.Memberships.Membership
  alias Order.Positions.Position
  alias Order.Organizations.Organization
  alias Order.Tenures.Tenure

  def list_tenures(%User{} = user) do
    Repo.all(
      from t in Tenure,
        join: m in Membership,
        on: t.membership_id == m.id,
        join: p in Position,
        on: t.position_id == p.id,
        join: o in Organization,
        on: p.organization_id == o.id,
        where: m.user_id == ^user.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            first_name: m.first_name,
            last_name: m.last_name
          },
          position: %{
            id: p.id,
            title: p.name
          },
          organization: %{
            id: o.id,
            name: o.name
          }
        }
    )
  end

  def list_tenures(%Membership{} = membership) do
    Repo.all(
      from t in Tenure,
        join: p in Position,
        on: t.position_id == p.id,
        join: o in Organization,
        on: p.organization_id == o.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          organization: %{
            id: o.id,
            name: o.name
          },
          position: %{
            id: p.id,
            name: p.name
          }
        },
        where: t.membership_id == ^membership.id
    )
  end

  def list_tenures(%Position{} = position) do
    Repo.all(
      from t in Tenure,
        join: m in Membership,
        on: t.membership_id == m.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            name: m.name,
            email: m.email
          }
        },
        where: t.position_id == ^position.id
    )
  end

  def list_tenures(%Organization{} = organization) do
    Repo.all(
      from t in Tenure,
        join: p in Position,
        on: t.position_id == p.id,
        join: m in Membership,
        on: t.membership_id == m.id,
        select: %{
          id: t.id,
          active_range: t.active_range,
          member: %{
            id: m.id,
            name: m.name,
            email: m.email
          },
          position: %{
            id: p.id,
            name: p.name
          }
        },
        where: p.organization_id == ^organization.id
    )
  end

  def create_tenure(%Membership{id: membership_id}, %Position{id: position_id}, attrs \\ %{}) do
    # TODO: build_assoc from member to positon and vice versa?
    %Tenure{
      position_id: position_id,
      membership_id: membership_id
    }
    |> Tenure.changeset(attrs)
    |> Repo.insert()
  end
end
