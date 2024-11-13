defmodule Order.MeetingsFixtures do
  def meeting_fixture(organization_id, attrs \\ %{}) do
    attrs = valid_meeting_attributes(attrs)

    %Order.Meetings.Meeting{
      organization_id: organization_id
    }
    |> Order.Meetings.Meeting.changeset(attrs)
    |> Order.Repo.insert!()
  end

  def valid_meeting_attributes(attrs) do
    Enum.into(attrs, %{
      title: "Some meeting",
      topic: "Some topic",
      date: ~D[2018-01-01],
      scheduled_start_time: ~T[09:00:00],
      scheduled_end_time: ~T[10:00:00]
    })
  end
end
