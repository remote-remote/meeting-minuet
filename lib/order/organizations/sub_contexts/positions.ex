defmodule Order.Organizations.Positions do
  alias Order.Repo
  alias Order.Organizations.{Position, Organization, Tenure}

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
    get_position!(organization.id, position_id)
  end

  def get_position!(org_id, position_id) do
    Position.q_get_with_tenures(org_id, position_id)
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

  def assign_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end

  def create_tenure(attrs) do
    %Tenure{}
    |> Tenure.changeset(attrs)
    |> IO.inspect(label: "create_tenure")
    |> Repo.insert()
  end
end
