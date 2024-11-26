defmodule MeetingMinuet.Reports.PositionReport do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions_reports" do
    belongs_to :report, MeetingMinuet.Reports.Report
    belongs_to :position, MeetingMinuet.Organizations.Position

    timestamps(type: :utc_datetime)
  end

  def changeset(%PositionReport{} = air, attrs \\ %{}) do
    air
    |> cast(attrs, [:report_id, :position_id])
    |> validate_required([:report_id, :position_id])
  end
end
