defmodule Order.Meetings.Permissions do
  alias Order.Meetings.Attendee

  def edit_meeting?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def edit_meeting?(a) when is_nil(a), do: false

  def delete_meeting?(%Attendee{roles: roles}) do
    Enum.member?(roles, :owner)
  end

  def delete_meeting?(a) when is_nil(a), do: false

  def cancel_meeting?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def cancel_meeting?(a) when is_nil(a), do: false

  def start_meeting?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def start_meeting?(a) when is_nil(a), do: false

  def manage_attendees?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def manage_attendees?(a) when is_nil(a), do: false

  def edit_minutes?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner, :scribe] end)
  end

  def edit_minutes?(a) when is_nil(a), do: false

  def create_agenda?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def create_agenda?(a) when is_nil(a), do: false

  def edit_agenda?(%Attendee{roles: roles}) do
    Enum.any?(roles, fn role -> role in [:host, :owner] end)
  end

  def edit_agenda?(a) when is_nil(a), do: false
end
