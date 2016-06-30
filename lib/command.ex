defmodule Slackmine.Commands do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name __MODULE__

  # API

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_command(command, args, channel, user) do
    child_id = {command, channel}
    Supervisor.delete_child(@name, child_id)
    worker = Supervisor.Spec.worker(command, [args, channel, user], function: :call, id: child_id,  restart: :transient)
    Supervisor.start_child(@name, worker)
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

  def post_users(users, channel, slack_api\\Slackmine.Slack)
  def post_users({:ok, users}, channel, slack_api) do
    post_users(users, channel, slack_api)
  end
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

defmodule Slackmine.Command.ResolveIssue do
  @behaviour Slackmine.Command
  @slack_api Slackmine.Slack

  def parse(_text), do: false
  def call({"", parent_pid}, channel_str, _user) do
    {:ok, channel} = Slackmine.Channels.get(channel_str)
    issues = Slackmine.Channel.get_issues(channel)

    cond do
      length(issues) == 0 ->
        @slack_api.message([channel_str], "Can't find issue.")
        send(parent_pid, {:notfound})
      length(issues) > 1 ->
        @slack_api.message([channel_str], "Too many issues.")
        send(parent_pid, {:notfound})
      length(issues) == 1 -> send(parent_pid, {:issue, hd(issues)})
    end
  end
end
