defmodule Slackmine.Command.Assign do
  @behaviour Slackmine.Command

  @rex ~r/[aA]ssign (?<issue>\S*)(?:\s*)to (?<user>\S*)/i
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]
  @slack_api Slackmine.Slack

  def parse(text) do
    case Regex.named_captures(@rex, text) do
      nil -> :nomatch
      matches -> {:match, matches}
    end
  end

  def call(%{"issue" => "", "user" => "me"}, channel_str, user) do
    spawn_link(Slackmine.Command.ResolveIssue, :call, [{"", self()}, channel_str, user])

    receive do
      {:issue, issue} ->
        case Slackmine.Users.get(user) do
          {:ok, user} ->
            @slack_api.message([channel_str], "Assigning ##{issue.id} to #{user}")
          :error ->
            @slack_api.message([channel_str], "But who are you?")
        end
        {:notfound} -> :ok
    end

    Process.exit(self(), :normal)
    {:ok, self()}
  end

  def call(%{"issue" => "#" <> id, "user" => "me"}, channel_str, user) do
    @slack_api.message([channel_str], "Assign ##{id} to #{user}")
  end

  def call(%{"issue" => "", "user" => assignee}, channel_str, _user) do
    @slack_api.message([channel_str], "Assign to #{assignee}")
  end
end
