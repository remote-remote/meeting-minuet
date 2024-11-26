defmodule MeetingMinuet.Meetings do
  import Ecto.Query
  alias MeetingMinuet.Meetings.AgendaItem
  alias MeetingMinuet.Repo
  alias MeetingMinuet.Meetings.Meeting
  alias MeetingMinuet.Organizations.{Organization, Membership}
  alias MeetingMinuet.Meetings.{Attendee, Attendees, Notifications}

  defdelegate list_attendees(meeting), to: Attendees
  defdelegate get_attendee(meeting, membership_id), to: Attendees
  defdelegate add_attendee(meeting, membership), to: Attendees
  defdelegate remove_attendee(meeting, membership_id), to: Attendees

  def list_agenda_items(meeting_id) do
    Repo.all(
      from i in AgendaItem,
        where: i.meeting_id == ^meeting_id,
        order_by: [asc: i.order],
        preload: [:position]
    )
  end

  def create_agenda_item!(attrs) do
    item_orders = list_agenda_items(attrs["meeting_id"]) |> Enum.reverse() |> Enum.map(& &1.order)
    order = List.first(item_orders, 0) + 100

    AgendaItem.create!(Map.put(attrs, "order", order))
  end

  def remove_agenda_item!(item_id) do
    Repo.delete!(%AgendaItem{id: item_id})
  end

  def move_agenda_item_up(item) do
    case Repo.all(
           from i in AgendaItem,
             where: i.meeting_id == ^item.meeting_id and i.order < ^item.order,
             order_by: [desc: i.order],
             limit: 2
         ) do
      [max] ->
        new_order = div(max.order, 2)
        update_agenda_item(item, %{order: new_order})

      [max, min] ->
        new_order = min.order + div(max.order - min.order, 2)
        update_agenda_item(item, %{order: new_order})

      [] ->
        nil
    end
  end

  def move_agenda_item_down(item) do
    case Repo.all(
           from i in AgendaItem,
             where: i.meeting_id == ^item.meeting_id and i.order > ^item.order,
             order_by: [asc: i.order],
             limit: 2
         ) do
      [min] ->
        new_order = min.order + 100
        update_agenda_item(item, %{order: new_order})

      [min, max] ->
        new_order = min.order + div(max.order - min.order, 2)
        update_agenda_item(item, %{order: new_order})

      [] ->
        nil
    end
  end

  def update_agenda_item(item, attrs) do
    item |> AgendaItem.changeset(attrs) |> Repo.update()
  end

  def is_attendee?(meeting_id, user_id) do
    attendee =
      from(a in Attendee,
        join: m in assoc(a, :membership),
        join: u in assoc(m, :user),
        where:
          a.meeting_id == ^meeting_id and
            u.id == ^user_id
      )
      |> Repo.one()

    !is_nil(attendee)
  end

  def get_meeting!(%Organization{} = organization, meeting_id) do
    Repo.one!(
      from m in Meeting,
        where: m.organization_id == ^organization.id and m.id == ^meeting_id
    )
  end

  def start_meeting(%Meeting{status: :scheduled} = meeting) do
    case Meeting.changeset(meeting, %{
           status: :in_progress,
           running_start_time: Time.utc_now()
         })
         |> Repo.update() do
      {:ok, meeting} ->
        Notifications.notify(meeting.id, {:meeting_started, meeting})
        {:ok, meeting}

      {:error, error} ->
        {:error, error}
    end
  end

  def start_meeting(%Meeting{}) do
    {:error, "Meeting is not scheduled"}
  end

  def end_meeting(%Meeting{status: :in_progress} = meeting) do
    case Meeting.changeset(meeting, %{
           status: :completed,
           running_end_time: Time.utc_now()
         })
         |> Repo.update() do
      {:ok, meeting} ->
        Notifications.notify(meeting.id, {:meeting_ended, meeting})
        {:ok, meeting}

      {:error, error} ->
        {:error, error}
    end
  end

  def end_meeting(%Meeting{}) do
    {:error, "Meeting is not in progress"}
  end

  def change_meeting(%Meeting{} = meeting, attrs \\ %{}) do
    Meeting.changeset(meeting, attrs)
  end

  def create_meeting(%Organization{} = organization, %Membership{} = membership, attrs) do
    %Meeting{
      organization_id: organization.id,
      attendees: [
        %Attendee{
          membership_id: membership.id,
          status: :invited,
          roles: [:owner]
        }
      ]
    }
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  def list_org_meetings(organization_id, query \\ [], opts \\ []) do
    Repo.all(
      from m in Meeting,
        where: m.organization_id == ^organization_id,
        where: ^query,
        preload: [:organization, :attendees],
        order_by: [desc: m.date, desc: m.scheduled_start_time],
        limit: ^opts[:limit]
    )
  end

  def list_user_meetings(user_id, query \\ [], opts \\ []) do
    Repo.all(
      from m in Meeting,
        where: ^query,
        join: a in assoc(m, :attendees),
        join: mb in assoc(a, :membership),
        where: mb.user_id == ^user_id,
        preload: [:organization, :attendees],
        order_by: [desc: m.date, desc: m.scheduled_start_time],
        limit: ^opts[:limit]
    )
  end
end
