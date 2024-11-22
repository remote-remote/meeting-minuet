defmodule MeetingMinuet.MeetingsFixtures do
  def meeting_fixture(organization_id, attrs \\ %{}) do
    attrs = valid_meeting_attributes(attrs)

    %MeetingMinuet.Meetings.Meeting{
      organization_id: organization_id
    }
    |> MeetingMinuet.Meetings.Meeting.changeset(attrs)
    |> MeetingMinuet.Repo.insert!()
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
