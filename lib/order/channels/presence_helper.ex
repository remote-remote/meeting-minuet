defmodule Order.PresenceHelper do
  defmacro __using__(opts) do
    quote do
      use Phoenix.Presence,
        otp_app: unquote(opts[:otp_app]) || :order,
        pubsub_server: unquote(opts[:pubsub_server]) || Order.PubSub

      @topic_prefix unquote(opts[:topic_prefix])

      alias Order.Accounts.User

      # Subscribe to the topic
      def subscribe(id) when is_integer(id) or is_binary(id) do
        Phoenix.PubSub.subscribe(Order.PubSub, topic(id))
      end

      def track_user(%User{} = user, id, meta) do
        track(self(), topic(id), user.id, meta)
      end

      def update_user(%User{} = user, id, update) do
        %{metas: [meta | _]} = get_by_key(topic(id), user.id)
        update(self(), topic(id), user.id, Map.merge(meta, update))
      end

      def list_users(id) when is_integer(id) or is_binary(id) do
        topic(id) |> list() |> simplify_presences()
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

      # Dynamic topic based on the given ID
      defp topic(id), do: "#{@topic_prefix}:presence:#{id}"
    end
  end
end
