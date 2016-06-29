defmodule Slackmine.Commands do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name __MODULE__

  # API

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_command(command, args, channel, user) do
    Supervisor.start_child(@name, {{command, channel}, {command, :call, [args, channel, user]}, :transient, 2000, :worker, :dynamic})
  end

  def apply_commands([cmd|rest], text, channel, user) do
    case cmd.parse(text) do
      :nomatch -> apply_commands(rest, text, channel, user)
      {:match, args} -> start_command(cmd, args, channel, user)
    end
  end

  def apply_commands([], _text, _channel, _user), do: :ok

  # SERVER

  def init(:ok) do
    children = []

    supervise(children, strategy: :one_for_one)
  end
end

defmodule Slackmine.Command do
  @slack_api Slackmine.Slack

  @callback parse(text :: String.t) :: :nomatch | {:match, %{}}
  @callback call(args :: %{}, channel :: String.t, user :: String.t) :: {:ok, pid}

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
