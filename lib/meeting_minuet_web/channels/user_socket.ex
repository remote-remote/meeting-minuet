defmodule MeetingMinuetWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel "chat:*", MeetingMinuetWeb.ChatChannel

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)

  # def connect(%{"token" => token}, socket, _connect_info) do
  #   case verify_user(token) do
  #     {:ok, user} ->
  #       {:ok, assign(socket, :user, user)}

  #     :error ->
  #       :error
  #   end
  # end

  # Allow anonymous connections for now
  def connect(_params, socket, _connect_info) do
    Logger.warning("Anonymous connection")
    {:ok, socket}
  end

  # Optionally, assign an ID to each socket for identification
  def id(_socket), do: nil

  # Implement your user verification logic
  defp verify_user(_token) do
    # For simplicity, we'll skip this
    {:ok, %{}}
  end
end
