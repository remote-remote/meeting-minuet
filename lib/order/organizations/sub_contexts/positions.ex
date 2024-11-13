defmodule Order.Organizations.Positions do
  import Ecto.Query
  alias Order.Repo
  alias Order.DB.{Organization, Position}

  # Positions

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
    Repo.all(
      from p in Ecto.assoc(organization, :positions),
        left_join: t in assoc(p, :tenures),
        on: fragment("t1.active_range @> ?::date", ^Date.utc_today()),
        left_join: m in assoc(t, :membership),
        left_join: u in assoc(m, :user),
        select: %{
          id: p.id,
          name: p.name,
          description: p.description,
          user: %{
            id: u.id,
            name: u.name,
            email: u.email,
            phone: u.phone
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
