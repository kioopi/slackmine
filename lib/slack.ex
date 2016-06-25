defmodule Slackmine.Slack.WithName do
  @moduledoc """
  Slack (Elixir-Slack) doesn't support registering the process to a name
  so this wrapper does this.

  There must be a better way to do it, but i coudn't get it to work in
  Slackmine.Slack.start_link/1
  """
  def start_link(name, bot) do
    {:ok, pid} = Slackmine.Slack.start_link(bot)
    Process.register(pid, name)
    {:ok, pid}
  end
end

defmodule Slackmine.Slack do
  @moduledoc """
  This is the interface to the Slack chat.

  Messages in slack arrive in the handle_message/3 function and
  are `send` to the process defined as the :bot option in `start_link`.


  The process accepts `:send` and `:typing` Elixir-messages and send
  the appropriate Slack-messages.

  These two features are also exposed as funcions on the module itself.
  `message/2` and `typing/1`

  """
  use Slack

  @token Application.get_env(:slackmine, __MODULE__)[:token]

  @doc """
  Starts the process that listens to slack messages.

  Called by the Supervisor in `lib/slackmine.ex` when the application starts.
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
    # FIXME: The name Slackmine.Slack is hardcoded here so if any other name is used
    # in Slackmine.Slack.WithName.start_link/2 this will break.
    send(Slackmine.Slack, {:send, chan, msg})
    message(channels, msg)
  end

  @doc """
  Indicates typing on a Slack channel.
  """
  def typing(channel) do
    send(Slackmine.Slack, {:typing, channel})
  end

  def direct_message(%{text: text, channel: chan, user: user}, slack, bot) do
    username = Slack.Lookups.lookup_user_name(user, slack)
    send(bot, {:direct_message, %{channel: chan, text: cut_bot_name(text, slack), user: username}})
  end

  def bot_name_string(%{me: %{ id: id}}) do
    "<@#{id}>"
  end

  def is_direct_message?(%{text: text}, slack) do
    String.starts_with?(text, bot_name_string(slack))
  end

  def cut_bot_name(text, slack) do
    String.slice(text, String.length(bot_name_string(slack)), 1000) |>
    String.trim(":") |>
    String.trim
  end

  ## callbacks

  @doc """
  Deals with incoming messages from Slack.

  Returns `{:ok, state}` with an updated state object.
  """
  def handle_message(message = %{type: "message"}, slack, state = %{bot: bot}) do
    if is_direct_message?(message, slack) do
      direct_message(message, slack, bot)
    else
      send(bot, {:message, message})
    end

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

  # fixme:

  # This is an attempt to create a slack attachment for an issue
  # https://api.slack.com/docs/attachments
  # works in the "message builder" (https://api.slack.com/docs/formatting/builder)
  # but doesn't seem to work via Elixir-Slack:
  # issue |> attachment_json(state.channel) |> send_raw(slack)
  #
  # The reason is that Slack RTM doesn't support attachments
  # https://api.slack.com/rtm#formatting_messages
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

defmodule Slackmine.Slack.Mock do
  def start_link(_name, _bot) do
    {:ok, self()}
  end

  def message(_channels, _msg) do
  end

  def typing(_channels, _msg) do
  end
end
