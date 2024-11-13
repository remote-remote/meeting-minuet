defmodule Order.Meetings do
  import Ecto.Query
  alias Order.Organizations
  alias Order.Repo
  alias Order.Organizations.{Organization, Membership, Members}
  alias Order.Meetings.{Meeting, Attendee}

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
    |> Repo.preload(membership: [:user, tenures: :position])
    |> Enum.map(fn a ->
      map_attendee(a)
    end)
  end

  def list_uninvited_members(%Meeting{} = meeting) do
    # TODO: optimize this somehow
    invited_member_ids = list_attendees(meeting) |> Enum.map(& &1.id)

    Members.list_members(meeting.organization_id)
    |> Enum.reject(fn m ->
      m.id in invited_member_ids
    end)
  end

  def add_attendee(%Meeting{} = meeting, %Membership{} = membership) do
    add_attendee(meeting, membership.id)
  end

  def add_attendee(%Meeting{} = meeting, membership_id) when is_integer(membership_id) do
    # TODO: don't allow duplicates
    # TODO: don't allow adding members from other organizations
    result =
      Ecto.build_assoc(meeting, :attendees)
      |> Attendee.changeset(%{membership_id: membership_id, status: "invited"})
      |> Repo.insert()

    case result do
      {:ok, attendee} ->
        member = Members.get_member!(meeting.organization_id, membership_id)
        {:ok, map_attendee(attendee, member)}

      {:error, changeset} ->
        changeset
    end
  end

  def remove_attendee(%Meeting{} = meeting, membership_id) do
    Repo.delete_all(
      from a in Attendee,
        where: a.meeting_id == ^meeting.id and a.membership_id == ^membership_id
    )
  end

  defp map_attendee(%Attendee{} = a) do
    %{
      # Attendee stuff
      id: a.membership_id,
      attendee_id: a.id,
      status: a.status,
      rsvp_date: a.rsvp_date,
      marked_present_at: a.marked_present_at,
      in_person: a.in_person,
      online: a.online,
      # Member stuff
      user_id: a.membership.user_id,
      name: a.membership.user.name,
      email: a.membership.user.email,
      phone: a.membership.user.phone,
      current_positions: a.membership.tenures |> Enum.map(& &1.position.name)
    }
  end

  defp map_attendee(%Attendee{} = a, %Organizations.Member{} = m) do
    %{
      # Attendee stuff
      id: a.membership_id,
      attendee_id: a.id,
      status: a.status,
      rsvp_date: a.rsvp_date,
      marked_present_at: a.marked_present_at,
      in_person: a.in_person,
      online: a.online,
      # Member stuff
      user_id: m.user_id,
      name: m.name,
      email: m.email,
      phone: m.phone,
      current_positions: m.current_positions
    }
  end
end
