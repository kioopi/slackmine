defmodule Slackmine.Commands do
  def handle_message([cmd|rest], text, channel, user) do
    case cmd.handle_message(text, channel, user) do
      :nomatch -> handle_message(rest, text, channel, user)
      :ok -> :ok
    end
  end

  def handle_message([], _text, _channel, _user), do: :ok
end

defmodule Slackmine.Command do
  @slack_api Slackmine.Slack

  defmacro __using__(_opts) do
    quote do
      @behaviour Slackmine.Command

      def handle_message(text, channel, user) do
        case parse(text) do
          :nomatch -> :nomatch
          {:match, args} -> call(args, channel, user)
        end
      end
    end
  end

  @callback parse(text :: String.t) :: :nomatch | {:match, %{}}
  @callback call(args :: %{}, channel :: String.t, user :: String.t) :: :ok

  def post_users(users, channel, slack_api\\Slackmine.Slack )
  def post_users([user|users], channel, slack_api) do
    slack_api.message([channel], to_string(user))
    post_users(users, channel, slack_api)
  end
  def post_users([], _channel, _slack_api), do: :ok

  def nl_join(enum, join \\ "and") do
    first = Enum.map(enum, &to_string/1) |>
    Enum.take(length(enum)-1) |>
    Enum.join(", ")
    Enum.join([first , List.last(enum)], " #{join} ")
  end
end
