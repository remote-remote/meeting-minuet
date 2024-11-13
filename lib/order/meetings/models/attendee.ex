defmodule Order.Meetings.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendees" do
    field :status, Ecto.Enum,
      values: [:invited, :accepted, :present, :attended, :absent, :declined],
      default: :invited

    field :rsvp_date, :utc_datetime
    field :marked_present_at, :utc_datetime
    field :in_person, :boolean
    field :online, :boolean
    field :roles, {:array, Ecto.Enum}, values: [:attendee, :host, :owner], default: [:attendee]

    belongs_to :meeting, Order.Meetings.Meeting
    belongs_to :membership, Order.Organizations.Membership

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
      :online,
      :roles
    ])
    |> validate_required([:status, :meeting_id, :membership_id, :roles])
  end
end
