defmodule Slackmine.ChannelsTest do
  use ExUnit.Case, async: true

  alias Slackmine.Channels

  test "spawns channels" do
    # get a new channel
    {:ok, channel }= Channels.get("CHANNEL")

    # use the channel 
    Slackmine.Channel.put(channel, "milk", 1)
    assert Slackmine.Channel.get(channel, "milk") == 1

    # get another channel
    { :ok, _channel_b } = Channels.get("CHANNEL_B")

    # get first channel again
    { :ok, first } = Channels.get("CHANNEL")
    assert Slackmine.Channel.get(first, "milk") == 1
  end

  test "removes channels on exit" do
    { :ok, channel } = Channels.get("CHANNEL")
    Slackmine.Channel.put(channel, "milk", 1)

    Agent.stop(channel)

    { :ok, same } = Channels.get("CHANNEL")
    Slackmine.Channel.put(same, "milk", 1)  # new channel data
  end

  test "removes channels on crash" do
    {:ok, channel} = Channels.get("CHANNEL")

    # Stop the bucket with non-normal reason
    Process.exit(channel, :shutdown)

    # Wait until the bucket is dead
    ref = Process.monitor(channel)
    assert_receive {:DOWN, ^ref, _, _, _}

    {:ok, newchannel} = Channels.get("CHANNEL")

    Slackmine.Channel.put(newchannel, "xxx", 1)  # new channel data
  end
end
