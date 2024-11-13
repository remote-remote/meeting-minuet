defmodule Order.Meetings.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendees" do
    field :status, Ecto.Enum,
      values: [:invited, :accepted, :present, :attended, :absent, :declined]

    field :meeting_id, :id
    field :member_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
