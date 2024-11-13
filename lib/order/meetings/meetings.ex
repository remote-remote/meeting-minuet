defmodule Order.Meetings do
  import Ecto.Query
  alias Order.Repo
  alias Order.Meetings.Meeting
  alias Order.Organizations.{Organization, Membership}
  alias Order.Meetings.{Attendee, Attendees, Notifications}

  defdelegate list_attendees(meeting), to: Attendees
  defdelegate get_attendee(meeting, membership_id), to: Attendees
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
