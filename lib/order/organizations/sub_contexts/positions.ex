defmodule Order.Organizations.Positions do
  import Ecto.Query
  import Order.DateHelper
  alias Order.DB
  alias Order.Repo
  alias Order.Organizations.{Position, Tenure, Organization}

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
    |> Position.to_db()
    |> Repo.update()
  end

  def list_positions(%Organization{} = organization) do
    DB.Position.q_list_with_tenures(organization.id)
    |> Repo.all()
    |> Enum.map(&Position.from_db/1)
  end

  def get_position!(%Organization{} = organization, position_id) do
    DB.Position.q_get_with_tenures(organization.id, position_id)
    |> Repo.one!()
    |> Position.from_db()
  end

  def get_position!(position_id) do
    Repo.get(DB.Position, position_id)
  end

  def create_position(%Organization{} = organization, attrs) do
    %DB.Position{organization_id: organization.id}
    |> DB.Position.changeset(attrs)
    |> Repo.insert()
  end
end
