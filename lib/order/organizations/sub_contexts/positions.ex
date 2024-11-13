defmodule Order.Organizations.Positions do
  alias Order.Repo
  alias Order.Organizations.{Position, Organization}

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

  def list_positions(organization_id) do
    Position.q_list_with_tenures(organization_id)
    |> Repo.all()
  end

  def get_position!(%Organization{} = organization, position_id) do
    Position.q_get_with_tenures(organization.id, position_id)
    |> Repo.one!()
  end

  def get_position!(position_id) do
    Repo.get(Position, position_id)
  end

  def create_position(%Organization{} = organization, attrs) do
    %Position{organization_id: organization.id}
    |> Position.changeset(attrs)
    |> Repo.insert()
  end
end
