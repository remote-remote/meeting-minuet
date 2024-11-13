defmodule Order.Meetings.Attendees do
  import Ecto.Query
  import Order.DateHelper
  alias Order.Organizations
  alias Order.Repo
  alias Order.DB.{Membership, Meeting, Attendee}

  def list_attendees(%Meeting{} = meeting) do
    Repo.all(from(a in Ecto.assoc(meeting, :attendees)))
    |> Repo.preload(membership: [:user, tenures: :position])
    |> Enum.map(fn a ->
      map_attendee(a)
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
        {:ok, map_attendee(attendee)}

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

  defp map_attendee(_, d \\ Date.utc_today())

  defp map_attendee(
         %Attendee{membership: %Ecto.Association.NotLoaded{}} = a,
         date
       ),
       do: map_attendee(Repo.preload(a, membership: [:user, tenures: :position]), date)

  defp map_attendee(
         %Attendee{membership: %Membership{user: %Ecto.Association.NotLoaded{}}} = a,
         date
       ),
       do: map_attendee(%{a | membership: Repo.preload(a.membership, user: :tenures)}, date)

  # TODO: one level deeper

  defp map_attendee(%Attendee{} = a, %Date{} = date),
    do: %{
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
      current_positions:
        a.membership.tenures
        |> Enum.filter(fn t ->
          in_range?(t.active_range, date)
        end)
        |> Enum.map(fn t ->
          %{
            position_id: t.position_id,
            tenure_id: t.id,
            name: t.position.name,
            description: t.position.description,
            active_range: t.active_range
          }
        end)
    }

  defp map_attendee(%Attendee{} = a, %Organizations.Member{} = m),
    do: %{
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
