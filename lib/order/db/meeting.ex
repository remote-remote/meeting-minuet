defmodule Order.DB.Meeting do
  use Ecto.Schema
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

    belongs_to :organization, Order.Organizations.Organization
    has_many :attendees, Order.DB.Attendee
    has_many :users, through: [:attendees, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Order.DB.Meeting{} = meeting, attrs) do
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

  def cast_range(changeset, field, start_field, end_field) do
    start_time = get_change(changeset, start_field)
    end_time = get_change(changeset, end_field)

    case {start_time, end_time} do
      {nil, nil} ->
        changeset

      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {start_time, end_time} ->
        put_change(changeset, field, %Postgrex.Range{
          lower: start_time,
          upper: end_time,
          lower_inclusive: true,
          upper_inclusive: true
        })
    end
  end
end
