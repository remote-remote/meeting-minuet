defmodule Order.Meetings do
  import Ecto.Query
  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Meetings.Meeting
  alias Order.Meetings.Attendee, warn: false
  alias Order.Memberships.Membership
  alias Order.Memberships

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

  def list_attendees(%Meeting{} = meeting) do
    Repo.all(from(a in Ecto.assoc(meeting, :attendees)))
    |> Repo.preload(membership: [:user])
  end

  def list_uninvited_members(%Meeting{} = meeting) do
    Repo.all(
      from m in Membership,
        left_join: a in Attendee,
        on: a.membership_id == m.id and a.meeting_id == ^meeting.id,
        where: is_nil(a.id) and m.organization_id == ^meeting.organization_id,
        preload: [:user, :positions]
    )
  end

  def add_attendee(%Meeting{} = meeting, %Membership{} = membership) do
    add_attendee(meeting, membership.id)
  end

  def add_attendee(%Meeting{} = meeting, membership_id) when is_binary(membership_id) do
    result =
      Ecto.build_assoc(meeting, :attendees)
      |> Attendee.changeset(%{membership_id: membership_id, status: "invited"})
      |> Repo.insert()

    case result do
      {:ok, attendee} ->
        {:ok, Repo.preload(attendee, membership: [:user])}

      {:error, changeset} ->
        changeset
    end
  end

  def remove_attendee(%Meeting{} = meeting, attendee_id) do
    Repo.delete_all(
      from a in Attendee,
        where: a.meeting_id == ^meeting.id and a.id == ^attendee_id
    )
  end
end
