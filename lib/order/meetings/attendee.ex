defmodule Order.Meetings.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendees" do
    field :status, Ecto.Enum,
      values: [:invited, :accepted, :present, :attended, :absent, :declined]

    field :rsvp_date, :utc_datetime
    field :marked_present_at, :utc_datetime
    field :in_person, :boolean
    field :online, :boolean

    belongs_to :meeting, Order.Meetings.Meeting
    belongs_to :membership, Order.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [
      :status,
      :meeting_id,
      :membership_id,
      :rsvp_date,
      :marked_present_at,
      :in_person,
      :online
    ])
    |> validate_required([:status, :meeting_id, :membership_id])
  end
end
