defmodule Slackmine.ChannelTest do
  use ExUnit.Case, async: true

  alias Slackmine.Channel

  setup do
    {:ok, channel} = Channel.start_link
    {:ok, channel: channel}
  end

  test "handles issues", %{channel: channel} do
    Channel.add_issue(channel, 1);
    assert Channel.get_issues(channel) == [1]
  end

  test "stores values by key", %{channel: channel} do
    assert Channel.get(channel, "milk") == nil

    Channel.put(channel, "milk", 3)
    assert Channel.get(channel, "milk") == 3
  end

  test "can delete values", %{channel: channel} do
    assert Channel.get(channel, "milk") == nil

    Channel.put(channel, "milk", 3)
    Channel.put(channel, "honey", "bee")
    assert Channel.get(channel, "honey") == "bee"
    Channel.delete(channel, "honey")
    assert Channel.get(channel, "milk") == 3
    assert Channel.get(channel, "honey") == nil
  end
end
