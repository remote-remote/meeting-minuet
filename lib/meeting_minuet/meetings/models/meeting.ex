defmodule MeetingMinuet.Meetings.Meeting do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "meetings" do
    field :status, Ecto.Enum,
      values: [:scheduled, :in_progress, :completed, :cancelled],
      default: :scheduled

    field :title, :string
    field :topic, :string
    field :date, :date
    field :scheduled_start_time, :time
    field :scheduled_end_time, :time
    field :running_start_time, :time
    field :running_end_time, :time
    field :timezone, :string
    field :location, :string

    belongs_to :organization, MeetingMinuet.Organizations.Organization
    has_many :attendees, MeetingMinuet.Meetings.Attendee
    has_many :users, through: [:attendees, :user]
    has_many :agenda_items, MeetingMinuet.Meetings.AgendaItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Meeting{} = meeting, attrs) do
    meeting
    |> cast(attrs, [
      :status,
      :title,
      :topic,
      :organization_id,
      :date,
      :scheduled_start_time,
      :scheduled_end_time,
      :running_start_time,
      :running_end_time,
      :timezone,
      :location
    ])
    |> validate_required([
      :title,
      :topic,
      :status,
      :organization_id,
      :date,
      :scheduled_start_time
    ])
  end

  def q_list_for_org(org_id) do
    from m in Meeting,
      join: o in assoc(m, :organization),
      where: o.id == ^org_id
  end
end
