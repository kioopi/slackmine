defmodule SlackTest do
  use ExUnit.Case
  doctest Slackmine.Slack

  defmodule FakeWebsocketClient do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "Sends a message to the Bot" do
    Slackmine.Slack.handle_message(%{type: "message", text: "Hello", channel: "CHAN", user: "USER"}, %{ me: %{ id: "UBOT" }, users: %{"USER"=>%{name: "user"}}}, %{bot: self()})

    assert_receive({:message, %{channel: "CHAN", text: "Hello"}})
  end

  test "Sends a different message if bot is addressed directly" do
    Slackmine.Slack.handle_message(%{type: "message", text: "<@UBOT>: Hello", channel: "CHAN", user: "USER"}, %{ me: %{ id: "UBOT" }, users: %{"USER"=>%{name: "user"}}}, %{bot: self()})

    assert_receive({:direct_message, %{channel: "CHAN", text: "Hello", user: "@user"}})
  end

  test "Messages by the bot itself are ignored" do
    Slackmine.Slack.handle_message(%{type: "message", text: "Hello", channel: "CHAN", user: "UBOT"}, %{ me: %{ id: "UBOT" }, users: %{"UBOT"=>%{name: "bot"}}}, %{bot: self()})

    refute_receive({:message, %{channel: "CHAN", text: "Hello", user: "@bot"}})
  end
end
