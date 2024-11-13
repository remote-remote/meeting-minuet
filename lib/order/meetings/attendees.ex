defmodule Order.Meetings.Attendees do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendees" do
    field :meeting_id, :id
    field :attendees, {:array, :id}
  end

  @doc false
  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
