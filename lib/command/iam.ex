defmodule Slackmine.Command.Iam do
  @behaviour Slackmine.Command

  @rex ~r/i am/i
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]
  @slack_api Slackmine.Slack

  def parse(text) do
    if Regex.match?(@rex, text) do
      {:match, %{term: search_term(text)}}
    else
      :nomatch
    end
  end

  def call(%{term: term}, channel, user) do
    case Slackmine.Users.get(user) do
      {:ok, user} ->
        @slack_api.message([channel], "Haven't we met before, #{user}?")
      :error ->
        pid = spawn_link(__MODULE__, :receive_users, [channel, user])
        @redmine_api.users(pid, term)
    end
    Process.exit(self(), :normal)
    {:ok, self()}
  end

  def receive_users(channel, user) do
    receive do
      {:users, users} -> cond do
        length(users) == 1 ->
          Slackmine.Users.add(user, hd(users))
          @slack_api.message([channel], "Nice to meet you, #{hd(users)}!")
        length(users) == 0 ->
          @slack_api.message([channel], "User not found")
        length(users) > 0 ->
          @slack_api.message([channel], "Which one? #{Slackmine.Command.nl_join(users, "or")}")
      end
    end
  end

  defp search_term(text) do
    String.split(text) |> Enum.slice(2, 1000) |> Enum.join(" ")
  end
end
