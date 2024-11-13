defmodule Order.Positions do
  import Ecto.Query, warn: false
  alias Order.Repo
  # alias Order.Accounts.User
  # alias Order.Members.Member
  alias Order.Positions.Position
  alias Order.Organizations.Organization

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
      from p in Position,
        where: p.organization_id == ^organization.id,
        select: %{
          id: p.id,
          title: p.name,
          description: p.description
          # TODO: join member from active tenure
        }
    )
  end

  def create_position(%Organization{id: organization_id}, attrs) do
    %Position{}
    |> Position.changeset(Map.put(attrs, "organization_id", organization_id))
    |> Repo.insert()
  end
end
