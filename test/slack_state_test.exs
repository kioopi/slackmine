defmodule SlackStateTest do
  use ExUnit.Case
  doctest Slackmine.Slack.State
  alias Slackmine.Slack.State

  test "mark_issue_as_pending puts channels waiting for issue into state " do
    state = %{pending_issues: %{}}
    new_state = State.mark_issue_as_pending(state, "1", "channel")
    assert new_state.pending_issues["1"] == ["channel"]
  end

  test "mark_issue_as_pending can deal with serval channels waiting for an issue" do
    state = %{pending_issues: %{"2" => ["CA"]}}
    new_state = State.mark_issue_as_pending(state, "2", "CB")
    assert new_state.pending_issues["2"] == ["CB", "CA"]
  end

  test "mark_issue_as_pending can handle multiple issues" do
    state = %{pending_issues: %{"1" => ["CA"]}}
    new_state = State.mark_issue_as_pending(state, "2", "CB")
    assert new_state.pending_issues["1"] == ["CA"]
    assert new_state.pending_issues["2"] == ["CB"]
  end

  test "remove_pending_issue removes pending issue from state" do
    state = %{pending_issues: %{"1" => ["CA"]}}
    new_state = State.remove_pending_issue(state, "1")
    assert new_state.pending_issues == %{}
  end

  test "remove_pending_issue leaves other issues untouched" do
    state = %{pending_issues: %{"1" => ["CHANNEL"], "2" => ["TUNNEL"]}}
    new_state = State.remove_pending_issue(state, "1")
    assert new_state.pending_issues == %{"2" => ["TUNNEL"]}
  end

  test "remove_pending_issue returns state if issue not found" do
    state = %{pending_issues: %{"1" => ["CHANNEL"], "2" => ["TUNNEL"]}}
    new_state = State.remove_pending_issue(state, "3")
    assert new_state == state
  end

  test "remove_pending_issue accepts ticket ids as integer" do
    state = %{pending_issues: %{"1" => ["CHANNEL"]}}
    new_state = State.remove_pending_issue(state, 1)
    assert new_state.pending_issues == %{}
  end

  test "get_channels_for_pending_issue returns list of channels" do
    state = %{pending_issues: %{"1" => ["CHANNEL"]}}
    channels = State.get_channels_for_pending_issue(state, "1")
    assert channels == ["CHANNEL"]
  end

  test "get_channels_for_pending_issue accepts issue id as integer" do
    state = %{pending_issues: %{"1" => ["CHANNEL"]}}
    channels = State.get_channels_for_pending_issue(state, 1)
    assert channels == ["CHANNEL"]
  end
end
