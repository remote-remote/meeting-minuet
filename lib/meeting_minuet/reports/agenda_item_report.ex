defmodule MeetingMinuet.Reports.AgendaItemReport do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset

  schema "agenda_items_reports" do
    belongs_to :report, MeetingMinuet.Reports.Report
    belongs_to :agenda_item, MeetingMinuet.Meetings.AgendaItem

    timestamps(type: :utc_datetime)
  end

  def changeset(%AgendaItemReport{} = air, attrs \\ %{}) do
    air
    |> cast(attrs, [:report_id, :agenda_item_id])
    |> validate_required([:report_id, :agenda_item_id])
  end
end
