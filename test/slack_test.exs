defmodule SlackTest do
  use ExUnit.Case
  doctest Slackmine.Slack

  defmodule FakeWebsocketClient do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "Sends a message to the Bot" do
    Slackmine.Slack.handle_message(%{type: "message", text: "Hello", channel: "CHAN"}, %{}, %{bot: self()})

    assert_receive({:message, %{channel: "CHAN", text: "Hello"}})
  end
end
