defmodule Order.Meetings do
  import Ecto.Query
  alias Order.Repo
  alias Order.DB.Meeting
  alias Order.Accounts.User
  alias Order.Organizations.Organization
  alias Order.Meetings.{Attendees, Notifications}

  defdelegate list_attendees(meeting), to: Attendees
  defdelegate add_attendee(meeting, membership), to: Attendees
  defdelegate remove_attendee(meeting, membership_id), to: Attendees

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

  def create_meeting(%Organization{} = organization, attrs) do
    %Meeting{organization_id: organization.id}
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  def list_meetings(subject, query \\ [], opts \\ [limit: 10])

  def list_meetings(%Organization{} = organization, query, opts) do
    Repo.all(
      from m in Meeting,
        where: m.organization_id == ^organization.id,
        where: ^query,
        order_by: [desc: m.date, desc: m.scheduled_start_time],
        limit: ^opts[:limit]
    )
  end

  def list_meetings(%User{} = user, query, opts) do
    Repo.all(
      from m in Meeting,
        where: ^query,
        join: a in assoc(m, :attendees),
        join: mb in assoc(a, :membership),
        where: mb.user_id == ^user.id,
        order_by: [desc: m.date, desc: m.scheduled_start_time],
        preload: [:organization],
        limit: ^opts[:limit]
    )
    |> Enum.map(&map_meeting/1)
  end

  defp map_meeting(%Meeting{} = m) do
    %{
      id: m.id,
      title: m.title,
      date: m.date,
      scheduled_start_time: m.scheduled_start_time,
      scheduled_end_time: m.scheduled_end_time,
      running_start_time: m.running_start_time,
      running_end_time: m.running_end_time,
      organization_id: m.organization_id,
      organization_name: m.organization.name,
      status: m.status
    }
  end
end
