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
    assert new_state == %{Slackmine.Bot.State.initial | pending_issues: %{ "1" => ["CHAN"] }}
  end

  test "nl_join returns string" do
    assert Slackmine.Bot.nl_join(["john-paul", "george", "ringo"]) == "john-paul, george and ringo"
    assert Slackmine.Bot.nl_join(["tick", 2, "track"], "und") == "tick, 2 und track"
    assert Slackmine.Bot.nl_join(["left", "right"], "or") == "left or right"
  end
end
