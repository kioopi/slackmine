defmodule BotTest do
  use ExUnit.Case
  doctest Slackmine.Bot
  alias Slackmine.Bot

  test "parse_issue_ids" do
    assert Bot.parse_issue_ids("No Issue ID") == []
    assert Bot.parse_issue_ids("#123") == ["123"]
    assert Bot.parse_issue_ids("An ID in #1234 a sentece.") == ["1234"]
    assert Bot.parse_issue_ids("#12,#34") == ["12", "34"]
  end

  test "get_issue adds id and channel to pending issues" do
    new_state = Bot.get_issue("1", "CHAN", Bot.State.initial)
    assert new_state == %{Bot.State.initial | pending_issues: %{ "1" => ["CHAN"] }}
  end

  test "incomming issues are added to context of channels" do
    issue = %Slackmine.Redmine.Issue{id: "1"}
    state_with_pending_issue = %{Bot.State.initial | pending_issues: %{ "1" => ["CHAN"] }}
    Bot.handle_info({:issue, issue}, state_with_pending_issue)
    {:ok, channel} = Slackmine.Channels.get("CHAN")
    assert Slackmine.Channel.get_issues(channel) == [issue]
  end
end
