defmodule Order.Meetings do
  import Ecto.Query, warn: false
  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Meetings.Meeting

  def change_meeting(%Meeting{} = meeting, attrs \\ %{}) do
    Meeting.changeset(meeting, attrs)
  end

  def create_meeting(attrs, %Organization{id: organization_id}) do
    %Meeting{
      organization_id: organization_id
    }
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
