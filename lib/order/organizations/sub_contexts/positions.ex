defmodule Order.Organizations.Positions do
  import Ecto.Query
  import Order.DateHelper
  alias Order.DB
  alias Order.Repo
  alias Order.Organizations.{Position, Tenure}

  # Positions

  @doc """
  Returns a Position changeset
  """
  def change_position(%DB.Position{} = position, attrs \\ %{}) do
    DB.Position.changeset(position, attrs)
  end

  def update_position(%DB.Position{} = position, attrs) do
    position
    |> DB.Position.changeset(attrs)
    |> Repo.update()
  end

  def list_positions(%DB.Organization{} = organization) do
    Repo.all(Ecto.assoc(organization, :positions))
    |> Repo.preload(tenures: :user)
    |> Enum.map(&map_position/1)
  end

  def get_position!(%DB.Organization{} = organization, position_id) do
    Repo.one!(
      from p in DB.Position,
        where: p.organization_id == ^organization.id and p.id == ^position_id
    )
  end

  def get_position!(position_id) do
    Repo.get(DB.Position, position_id)
  end

  def create_position(%DB.Organization{} = organization, attrs) do
    Ecto.build_assoc(organization, :positions)
    |> DB.Position.changeset(attrs)
    |> Repo.insert()
  end

  defp map_position(%DB.Position{tenures: %Ecto.Association.NotLoaded{}} = p) do
    Repo.preload(p, :tenures) |> map_position()
  end

  defp map_position(%DB.Position{} = p) do
    tenures = Enum.map(p.tenures, &map_tenure/1)

    %Position{
      id: p.id,
      name: p.name,
      description: p.description,
      current_tenures:
        tenures
        |> Enum.filter(&in_range?(&1.active_range, Date.utc_today())),
      past_tenures: tenures |> Enum.reject(&in_range?(&1.active_range, Date.utc_today()))
    }
  end

  defp map_tenure(%DB.Tenure{membership: %Ecto.Association.NotLoaded{}} = t) do
    Repo.preload(t, :user) |> map_tenure()
  end

  defp map_tenure(%DB.Tenure{} = t) do
    %Tenure{
      name: t.user.name,
      email: t.user.email,
      phone: t.user.phone,
      active_range: t.active_range
    }
  end
end
