defmodule Slackmine.Command.Users do
  @behaviour Slackmine.Command

  @rex ~r/user/
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]
  @slack_api Slackmine.Slack

  def parse(text) do
    if Regex.match?(@rex, text) do
      {:match, %{term: search_term(text)}}
    else
      :nomatch
    end
  end

  def call(%{term: term}, channel, _user) do
    pid = spawn_link(__MODULE__, :receive_users, [channel])
    @redmine_api.users(pid, term)
    {:ok, self()}
  end

  def receive_users(channel) do
    receive do
      {:users, users} -> Slackmine.Command.post_users(users, channel)
    end
  end

  defp search_term(text) do
    term = List.last(String.split(text))
    if Regex.match?(@rex, term), do: "", else: term
  end
end
