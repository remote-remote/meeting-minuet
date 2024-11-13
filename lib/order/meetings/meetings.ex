defmodule Order.Meetings do
  import Ecto.Query
  alias Order.Repo
  alias Order.DB.{Organization, Meeting}
  alias Order.Meetings.Attendees

  defdelegate list_attendees(meeting), to: Attendees
  defdelegate add_attendee(meeting, membership), to: Attendees
  defdelegate remove_attendee(meeting, membership_id), to: Attendees

  def get_meeting!(%Organization{} = organization, meeting_id) do
    Repo.one!(
      from m in Ecto.assoc(organization, :meetings),
        where: m.id == ^meeting_id
    )
  end

  def change_meeting(%Meeting{} = meeting, attrs \\ %{}) do
    Meeting.changeset(meeting, attrs)
  end

  def create_meeting(%Organization{} = organization, attrs) do
    Ecto.build_assoc(organization, :meetings)
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  def list_meetings(%Organization{} = organization) do
    Repo.all(
      from m in Meeting,
        where: m.organization_id == ^organization.id,
        order_by: [desc: m.date, desc: m.scheduled_start_time],
        limit: 10
    )
  end
end
