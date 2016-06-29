defmodule Slackmine.Command.Assign do
  use Slackmine.Command

  @rex ~r/[aA]ssign (?<issue>\S*)(?:\s*)to (?<user>\S*)/i
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]
  @slack_api Slackmine.Slack

  def parse(text) do
    case Regex.named_captures(@rex, text) do
      nil -> {:nomatch}
      matches -> {:match, matches}
    end
  end

  def call(%{"issue" => "", "user" => "me"}, channel_str, user) do
    {:ok, channel} = Slackmine.Channels.get(channel_str)
    issues = Slackmine.Channel.get_issues(channel)
    cond do
      length(issues) == 0 -> @slack_api.message([channel_str], "Issue?")
      length(issues) > 1 -> @slack_api.message([channel_str], "Too many issues.")
      length(issues) == 1 ->
        case Slackmine.Users.get(user) do
          {:ok, user} ->
            @slack_api.message([channel_str], "Assigning ##{hd(issues).id} to #{user}")
          :error ->
            @slack_api.message([channel_str], "But who are you?")
        end
    end
  end

  def call(%{"issue" => "#" <> id, "user" => "me"}, channel_str, user) do
    @slack_api.message([channel_str], "Assign ##{id} to #{user}")
  end


  def call(%{"issue" => "", "user" => assignee}, channel_str, _user) do
    @slack_api.message([channel_str], "Assign to #{assignee}")
  end
end
