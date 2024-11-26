defmodule MeetingMinuet.Meetings.AgendaItem do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset
  alias MeetingMinuet.Repo

  schema "agenda_items" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:scheduled, :in_progress, :complete, :tabled]
    field :completed_at, :utc_datetime
    field :order, :integer

    field :position_id, :id, virtual: true

    belongs_to :meeting, MeetingMinuet.Meetings.Meeting
    has_one :agenda_item_report, MeetingMinuet.Reports.AgendaItemReport
    has_one :report, through: [:agenda_item_report, :report]
    has_one :position, through: [:report, :position]
    timestamps(type: :utc_datetime)
  end

  def changeset(%AgendaItem{} = agenda, attrs \\ %{}) do
    agenda
    |> cast(attrs, [:name, :description, :meeting_id, :status, :completed_at, :order])
    |> cast(attrs, [:position_id])
    |> validate_required([:name, :meeting_id, :order])
  end

  def create!(attrs) do
    cs = changeset(%AgendaItem{}, attrs)

    item = cs |> Repo.insert!()

    case get_change(cs, :position_id) do
      nil ->
        item

      position_id ->
        report =
          %MeetingMinuet.Reports.Report{text: ""}
          |> Repo.insert!()

        %MeetingMinuet.Reports.PositionReport{report_id: report.id, position_id: position_id}
        |> Repo.insert!()

        %MeetingMinuet.Reports.AgendaItemReport{report_id: report.id, agenda_item_id: item.id}
        |> Repo.insert!()

        item
    end
  end
end
