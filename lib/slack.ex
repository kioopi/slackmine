defmodule Slackmine.Slack.WithName do
  def start_link(name, bot) do
    {:ok, pid} = Slackmine.Slack.start_link(bot)
    Process.register(pid, name)
    {:ok, pid}
  end
end

defmodule Slackmine.Slack.Mock do
  def start_link(_name, _bot) do
    {:ok, self()}
  end

  def message(_channels, _msg) do
  end

  def typing(_channels, _msg) do
  end
end

defmodule Slackmine.Slack do
  @moduledoc """
  This is the interface to the Slack chat.

  Messages in slack arrive in the handle_message/3 function.
  """
  use Slack

  @token Application.get_env(:slackmine, __MODULE__)[:token]

  @doc """
  Starts the process that listens to slack messages.

  Called by the Supervisor in `lib/slackmine.ex` when the applicatoin starts.
  """
  def start_link(bot) do
    start_link(@token, %{bot: bot})
  end

  @doc """
  Sends a message to a list of slack channels.

  Returns `:ok`
  """
  def message([], _msg), do: :ok
  def message([chan|channels], msg) do
    send(Slackmine.Slack, {:send, chan, msg})
    message(channels, msg)
  end

  def typing(channel) do
    send(Slackmine.Slack, {:typing, channel})
  end

  ## callbacks

  @doc """
  Deals with incoming messages from Slack.

  Returns `{:ok, state}` with an updated state object.
  """
  def handle_message(%{type: "message", text: text, channel: channel}, _slack, state = %{bot: bot}) do
    send(bot, {:message, %{channel: channel, text: text}})
    {:ok, state}
  end
  def handle_message(_message, _slack, state), do: {:ok, state}

  def handle_info({:send, channel, text}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end

  def handle_info({:typing, channel}, slack, state) do
    indicate_typing(channel, slack)
    {:ok, state}
  end


  # fixme

  # This is an attempt to create a slack attachment for an issue
  # https://api.slack.com/docs/attachments
  # works in the "message builder" (https://api.slack.com/docs/formatting/builder)
  # but doesn't seem to work via Elixir-Slack:
  # issue |> attachment_json(state.channel) |> send_raw(slack)
  def attachment_json(issue, channel) do
    data = %{
      attachments: [%{
        fallback: issue.subject,
        color: "#36a64f",
        author_name: issue.author.name,
        title: issue.subject,
        title_link: issue.link,
        text: issue.description,
        pretext: "Pre text"
      }],
      type: "message",
      icon_url: "http://lorempixel.com/48/48/",
      text: "hoo",
      channel: channel
    }
    Poison.encode!(data)
  end
end
