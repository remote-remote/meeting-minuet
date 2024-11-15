defmodule OrderWeb.DTO.Tenure do
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

  def changeset(tenure, attrs) do
    tenure
    |> cast(attrs, [:position_id, :membership_id, :start_date, :end_date])
    |> validate_required([:position_id, :membership_id, :start_date])
    |> validate_date_range()
    |> validate_no_overlap()
    |> IO.inspect(label: "VALIDATION")
  end

  defp validate_no_overlap(%Ecto.Changeset{valid?: true} = changeset) do
    proposed_tenure = apply_changes(changeset) |> unmap()

    # TODO: Check this  a better way
    case Order.Organizations.tenures_overlap?(proposed_tenure) do
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

    if start_date && end_date && start_date > end_date do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end

  def map(%Order.Organizations.Tenure{id: nil}) do
    %OrderWeb.DTO.Tenure{}
  end

  def map(%Order.Organizations.Tenure{} = tenure) do
    %OrderWeb.DTO.Tenure{
      id: tenure.id,
      position_id: tenure.position_id,
      membership_id: tenure.membership_id,
      start_date: tenure.active_range.lower,
      end_date: tenure.active_range.upper
    }
  end

  def unmap_attrs(%OrderWeb.DTO.Tenure{} = tenure, attrs \\ %{}) do
    tenure
    |> changeset(attrs)
    |> apply_changes()
    |> (fn t ->
          %{
            position_id: t.position_id,
            membership_id: t.membership_id,
            active_range: %Postgrex.Range{lower: t.start_date, upper: t.end_date}
          }
        end).()
  end

  def unmap(%OrderWeb.DTO.Tenure{} = t) do
    %Order.Organizations.Tenure{
      id: t.id,
      position_id: t.position_id,
      membership_id: t.membership_id,
      active_range: %Postgrex.Range{lower: t.start_date, upper: t.end_date}
    }
  end
end
