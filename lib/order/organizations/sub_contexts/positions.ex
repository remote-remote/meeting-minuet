defmodule Order.Organizations.Positions do
  import Order.DateHelper
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

  def list_positions(%Organization{} = organization) do
    Position.q_list_with_tenures(organization.id)
    |> Repo.all()
    |> Enum.map(&map_position/1)
  end

  def get_position!(%Organization{} = organization, position_id) do
    Position.q_get_with_tenures(organization.id, position_id)
    |> Repo.one!()
  end

  def get_position!(position_id) do
    Repo.get(DB.Position, position_id)
  end

  def create_position(%Organization{} = organization, attrs) do
    %Position{organization_id: organization.id}
    |> Position.changeset(attrs)
    |> Repo.insert()
  end

  defp map_position(%Position{} = p) do
    tenures = Enum.map(p.tenures, &map_tenure/1)

    %{
      id: p.id,
      name: p.name,
      description: p.description,
      requires_report: p.requires_report,
      current_tenures:
        tenures
        |> Enum.filter(&in_range?(&1.active_range, Date.utc_today())),
      past_tenures: tenures |> Enum.reject(&in_range?(&1.active_range, Date.utc_today()))
    }
  end

  defp map_tenure(%Tenure{} = t) do
    %{
      name: t.user.name,
      membership_id: t.membership_id,
      position_id: t.position_id,
      email: t.user.email,
      phone: t.user.phone,
      active_range: t.active_range
    }
  end
end
