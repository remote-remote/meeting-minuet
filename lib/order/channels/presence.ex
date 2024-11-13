defmodule Order.Presence do
  use Phoenix.Presence,
    otp_app: :order,
    pubsub_server: Order.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Order.PubSub, topic)
  end

  def track_user(user, topic, meta) do
    track(self(), topic, user.id, meta)
  end

  def list_users(topic) do
    list(topic) |> simplify_presences()
  end

  def update_user(user, topic, update) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)
    update(self(), topic, user.id, Map.merge(meta, update))
  end

  def handle_diff(socket, diff) do
    socket |> remove_presences(diff.leaves) |> add_presences(diff.joins)
  end

  defp simplify_presences(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end)
  end

  defp remove_presences(socket, leaves) do
    Phoenix.Component.update(socket, :presences, fn p ->
      p
      |> Enum.filter(fn {id, _} -> !Map.has_key?(leaves, id) end)
      |> Enum.into(%{})
    end)
  end

  defp add_presences(socket, joins) do
    Phoenix.Component.update(socket, :presences, fn p ->
      Map.merge(p, simplify_presences(joins))
    end)
  end
end
