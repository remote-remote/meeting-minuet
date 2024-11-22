defmodule MeetingMinuet.Repo do
  use Ecto.Repo,
    otp_app: :meeting_minuet,
    adapter: Ecto.Adapters.Postgres
end
