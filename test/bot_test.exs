defmodule BotTest do
  use ExUnit.Case
  doctest Slackmine.Bot

  test "parse_issue_ids" do
    assert Slackmine.Bot.parse_issue_ids("No Issue ID") == []
    assert Slackmine.Bot.parse_issue_ids("#123") == ["123"]
    assert Slackmine.Bot.parse_issue_ids("An ID in #1234 a sentece.") == ["1234"]
    assert Slackmine.Bot.parse_issue_ids("#12,#34") == ["12", "34"]
  end

  test "get_issue adds id and channel to pending issues" do
    new_state = Slackmine.Bot.get_issue("1", "CHAN", Slackmine.Bot.State.initial)
    assert new_state == %{pending_issues: %{ "1" => ["CHAN"] }}
  end
end