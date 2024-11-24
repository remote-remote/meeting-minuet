defmodule MeetingMinuetWeb.DTO.Tenure do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :id
    field :position_id, :id
    field :membership_id, :id
    field :start_date, :date
    field :end_date, :date
  end

  def changeset(%MeetingMinuetWeb.DTO.Tenure{} = tenure, attrs) do
    tenure
    |> cast(attrs, [:position_id, :membership_id, :start_date, :end_date])
    |> validate_required([:position_id, :membership_id, :start_date])
    |> validate_date_range()
    |> validate_no_overlap()
  end

  def mapped_changeset(%MeetingMinuet.Organizations.Tenure{} = persistence_tenure, attrs) do
    persistence_tenure |> map() |> changeset(attrs)
  end

  def update(%MeetingMinuet.Organizations.Tenure{} = tenure, attrs) do
    case mapped_changeset(tenure, attrs) do
      %Ecto.Changeset{valid?: true} = changeset ->
        MeetingMinuet.Organizations.update_tenure(tenure, unmap_changes(changeset))

      changeset ->
        changeset
    end
  end

  def create(%MeetingMinuet.Organizations.Tenure{} = tenure, attrs) do
    case mapped_changeset(tenure, attrs) do
      %Ecto.Changeset{valid?: true} = changeset ->
        changeset
        |> apply_changes()
        |> unmap()
        |> Map.from_struct()
        |> MeetingMinuet.Organizations.create_tenure()

      changeset ->
        changeset
    end
  end

  def map(%MeetingMinuet.Organizations.Tenure{id: nil, position_id: position_id}) do
    %MeetingMinuetWeb.DTO.Tenure{} |> changeset(%{position_id: position_id}) |> apply_changes()
  end

  def map(%MeetingMinuet.Organizations.Tenure{} = tenure) do
    %MeetingMinuetWeb.DTO.Tenure{
      id: tenure.id,
      position_id: tenure.position_id,
      membership_id: tenure.membership_id,
      start_date: tenure.active_range.lower,
      end_date: tenure.active_range.upper
    }
  end

  def unmap(%MeetingMinuetWeb.DTO.Tenure{} = t) do
    %MeetingMinuet.Organizations.Tenure{
      id: t.id,
      position_id: t.position_id,
      membership_id: t.membership_id,
      active_range: %Postgrex.Range{lower: t.start_date, upper: t.end_date}
    }
  end

  defp unmap_changes(changeset) do
    changes = changeset.changes |> Map.reject(fn {k, _} -> k in [:start_date, :end_date] end)

    if changeset.changes |> Map.take([:start_date, :end_date]) |> map_size() do
      changeset
      |> apply_changes()
      |> unmap()
      |> Map.from_struct()
      |> Map.take([:active_range])
      |> Map.merge(changes)
    else
      changes
    end
  end

  defp validate_no_overlap(%Ecto.Changeset{valid?: true} = changeset) do
    proposed_tenure = apply_changes(changeset) |> unmap()

    case MeetingMinuet.Organizations.tenures_overlap?(proposed_tenure) do
      true ->
        changeset
        |> add_error(
          :start_date,
          "overlaps with existing tenure for this member and position"
        )
        |> add_error(
          :end_date,
          "overlaps with existing tenure for this member and position"
        )

      false ->
        changeset
    end
  end

  defp validate_no_overlap(changeset) do
    changeset
  end

  defp validate_date_range(changeset) do
    start_date = get_change(changeset, :start_date)
    end_date = get_change(changeset, :end_date)

    if not MeetingMinuet.DateHelper.lte?(start_date, end_date) do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
