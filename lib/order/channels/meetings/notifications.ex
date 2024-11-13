defmodule Order.Meetings.Notifications do
  alias Order.DB.Meeting
  alias Order.PubSub

  def notify(%Meeting{} = meeting, message) do
    notify(meeting.id, message)
  end

  def notify(meeting_id, message) do
    Phoenix.PubSub.broadcast(
      PubSub,
      topic(meeting_id),
      message
    )
  end

  def subscribe(%Meeting{} = meeting) do
    subscribe(meeting.id)
  end

  def subscribe(meeting_id) do
    Phoenix.PubSub.subscribe(PubSub, topic(meeting_id))
  end

  def topic(meeting_id) do
    "meetings:notifications:#{meeting_id}"
  end
end
