defmodule MeetingMinuet.Reports.Report do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :text, :string

    has_one :agenda_item_report, MeetingMinuet.Reports.AgendaItemReport
    has_one :agenda_item, through: [:agenda_item_report, :agenda_item]

    has_one :position_report, MeetingMinuet.Reports.PositionReport
    has_one :position, through: [:position_report, :position]

    timestamps(type: :utc_datetime)
  end

  def changeset(%Report{} = report, attrs \\ %{}) do
    report
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end

  def position_report_changeset(%Report{} = report, attrs \\ %{}) do
    report
    |> cast(attrs, [:text])
    |> validate_required([:text, :position])
    |> cast_assoc(:position, with: &MeetingMinuet.Organizations.Position.changeset/2)
  end

  def agenda_item_report_changeset(%Report{} = report, attrs \\ %{}) do
    report
    |> cast(attrs, [:text])
    |> cast_assoc(:agenda_item_report)
  end

  def agenda_item_position_report_changeset(%Report{} = report, attrs \\ %{}) do
    report
    |> cast(attrs, [:text])
    |> validate_required([:text, :position, :agenda_item])
    |> cast_assoc(:agenda_item, with: &MeetingMinuet.Meetings.AgendaItem.changeset/2)
    |> cast_assoc(:position, with: &MeetingMinuet.Organizations.Position.changeset/2)
  end
end
