defmodule SlackTest do
  use ExUnit.Case
  doctest Slackmine.Slack

  test "parse_issue_ids" do
    assert Slackmine.Slack.parse_issue_ids("No Issue ID") == []
    assert Slackmine.Slack.parse_issue_ids("#123") == ["123"]
    assert Slackmine.Slack.parse_issue_ids("An ID in #1234 a sentece.") == ["1234"]
    assert Slackmine.Slack.parse_issue_ids("#12,#34") == ["12", "34"]
  end


  # FIXME
  # def fake_send({:text, _json}, _socket), do: :ok

  # test "get_issue add id and channel to pending issues" do
  #   new_state = Slackmine.Slack.get_issue("1", "CHAN", %{socket: :socket, client: %{
  #   :send => &fake_send/2 }}, Slackmine.Slack.State.initial)
  #   assert new_state == %{pending_issues: %{ "1" => ["CHAN"] }}
  # end
end
