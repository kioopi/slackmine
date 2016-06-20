defmodule Slackmine.Slack do
  @moduledoc """
  This is the interface to the Slack chat.

  Messages in slack arrive in the handle_message/3 function.
  """
  use Slack
  alias Slackmine.Slack.State

  @token Application.get_env(:slackmine, __MODULE__)[:token]
  @redmine_api Application.get_env(:slackmine, __MODULE__)[:redmine_api]

  @doc """
  Starts the process that listens to slack messages.

  Called by the Supervisor in `lib/slackmine.ex` when the applicatoin starts.
  """
  def start_link do
    start_link(@token, State.initial)
  end

  @doc """
  Requests data about an Issue from Redmine.

  Returns new state object with issue marked as pending for channel.
  """
  def get_issue(id, channel, slack, state) do
    indicate_typing(channel, slack)
    @redmine_api.issue(self(), id)
    State.mark_issue_as_pending(state, id, channel)
  end

  def get_issues(ids, channel, slack, state) do
    Enum.reduce(ids, state, fn(id, state) -> get_issue(id, channel, slack, state) end)
  end

  @doc """
  Parses potential Redmine issue-ids from a string.

  Returns list of ids as strings.

  ## Examples

      iex> Slackmine.Slack.parse_issue_ids("Whats with #12345")
      ["12345"]
  """
  def parse_issue_ids(text) do
    for list <- Regex.scan(~r/#(\d+)/, text, capture: :all_but_first), do: hd(list)
  end

  @doc """
  Sends a message about an issue to a list of slack channels.

  Returns new state with the issue removed from prending_issues map.
  """
  def slack_issue(id, msg, slack, state) do
    State.get_channels_for_pending_issue(state, id) |>
    slack_msg(to_string(msg), slack)
    {:ok, State.remove_pending_issue(state, id)}
  end

  @doc """
  Sends a message to a list of slack channels.

  Returns `:ok`
  """
  def slack_msg([], _msg, _slack), do: :ok
  def slack_msg([chan|channels], msg, slack) do
    send_message(msg, chan, slack)
    slack_msg(channels, msg, slack)
  end

  ## callbacks

  @doc """
  Deals with incoming messages from Slack.

  Returns `{:ok, state}` with an updated state object.
  """
  def handle_message(%{type: "message", text: text, channel: channel}, slack, state) do
    case parse_issue_ids(text) do
      [] -> {:ok, state}
      issue_ids -> {:ok, get_issues(issue_ids, channel, slack, state)}
    end
  end
  def handle_message(_message, _slack, state), do: {:ok, state}

  # Slackmine.Redmine sends message {:issue, %Issue{}} when issue is
  # retrieved from redmine
  def handle_info({:issue, issue}, slack, state) do
    slack_issue(issue.id, issue, slack, state)
  end

  def handle_info({:issue_failed, id}, slack, state) do
    slack_issue(id, "Could not get info on issue #{id}, sorry.", slack, state)
  end
  def handle_info({:issue_failed, id, reason}, slack, state) do
    slack_issue(id, "Could not get info on issue #{id} because of #{reason}.", slack, state)
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
