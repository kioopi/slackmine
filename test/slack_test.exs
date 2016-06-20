defmodule SlackTest do
  use ExUnit.Case
  doctest Slackmine.Slack

  defmodule FakeWebsocketClient do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "parse_issue_ids" do
    assert Slackmine.Slack.parse_issue_ids("No Issue ID") == []
    assert Slackmine.Slack.parse_issue_ids("#123") == ["123"]
    assert Slackmine.Slack.parse_issue_ids("An ID in #1234 a sentece.") == ["1234"]
    assert Slackmine.Slack.parse_issue_ids("#12,#34") == ["12", "34"]
  end

  test "get_issue adds id and channel to pending issues" do
    new_state = Slackmine.Slack.get_issue("1", "CHAN", %{socket: nil, client: FakeWebsocketClient}, Slackmine.Slack.State.initial)
    assert new_state == %{pending_issues: %{ "1" => ["CHAN"] }}
  end
end
