defmodule MeetingMinuet.Organizations.Positions do
  import Ecto.Query
  alias MeetingMinuet.Repo
  alias MeetingMinuet.Organizations.{Position, Organization, Tenure}

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
    |> Repo.insert()
  end

  def update_tenure(%Tenure{} = tenure, attrs) do
    tenure
    |> Tenure.changeset(attrs)
    |> Repo.update()
  end

  def get_tenure!(org_id, tenure_id) do
    Tenure.q_get(org_id, tenure_id)
    |> Repo.one!()
  end

  def tenures_overlap?(proposed_tenure) do
    if is_nil(proposed_tenure.active_range) do
      false
    else
      from(t in Tenure,
        where:
          t.position_id == ^proposed_tenure.position_id and
            t.membership_id == ^proposed_tenure.membership_id and
            fragment("? && ?", t.active_range, ^proposed_tenure.active_range)
      )
      |> q_exclude_self(proposed_tenure)
      |> Repo.aggregate(:count) > 0
    end
  end

  defp q_exclude_self(q, tenure) do
    if Map.has_key?(tenure, :id) and not is_nil(tenure.id) do
      q |> where([t], t.id != ^tenure.id)
    else
      q
    end
  end
end
