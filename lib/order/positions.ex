defmodule Order.Positions do
  import Ecto.Query, warn: false
  alias Order.Repo
  alias Order.Accounts.User
  alias Order.Memberships.Membership
  alias Order.Positions.Position
  alias Order.Organizations.Organization
  alias Order.Tenures.Tenure

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
    # TODO: preload?
    Repo.all(
      from p in Position,
        where: p.organization_id == ^organization.id,
        left_join: t in Tenure,
        on: t.position_id == p.id and fragment("t1.active_range @> ?::date", ^Date.utc_today()),
        left_join: m in Membership,
        on: t.membership_id == m.id,
        left_join: u in User,
        on: u.id == m.user_id,
        select: %{
          id: p.id,
          title: p.name,
          description: p.description,
          user: %{
            id: u.id,
            name: u.name,
            email: u.email
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
