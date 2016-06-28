defmodule Slackmine.Command.Default do
  use Slackmine.Command
  @slack_api Slackmine.Slack

  def parse(text), do: {:match, %{text: text}}

  def call(%{text: text}, channel, _user) do
    @slack_api.message([channel], text <> "?")
    :ok
  end
end
