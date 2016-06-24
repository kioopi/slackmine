defmodule Slackmine.Bot do
  @moduledoc """
  Contains the main logic and is the interface between Slackmine.Slack
  and Slackmine.Redmine.

  Gets send :message -messages by Slackmine.Slack containing chat-messages.
  Uses the API of Slacmine.Redmine to request info about issues.
  Issues arrive as :issue -messages from Slackmine.Redmine.

  """

  use GenServer
  alias Slackmine.Bot.State

  @slack_api Slackmine.Slack
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]

  def start_link(name, _slack_api) do
    GenServer.start_link(__MODULE__, State.initial, name: name)
  end

  @doc """
  Requests data about an Issue from Redmine.

  Returns new state object with issue marked as pending for channel.
  """
  def get_issue(id, channel, state) do
    @redmine_api.issue(self(), id)
    State.mark_issue_as_pending(state, id, channel)
  end

  def get_issues(ids, channel, state) do
    Enum.reduce(ids, state, fn(id, state) -> get_issue(id, channel, state) end)
  end

  @doc """
  Parses potential Redmine issue-ids from a string.

  Returns list of ids as strings.

  ## Examples

      iex> Slackmine.Bot.parse_issue_ids("Whats with #12345")
      ["12345"]
  """
  def parse_issue_ids(text) do
    for list <- Regex.scan(~r/#(\d+)/, text, capture: :all_but_first), do: hd(list)
  end

  @doc """
  Sends a message about an issue to a list of slack channels.

  Returns new state with the issue removed from prending_issues map.
  """
  def slack_issue(id, msg, state) do
    State.get_channels_for_pending_issue(state, id) |>
    @slack_api.message(to_string(msg))
    {:noreply, State.remove_pending_issue(state, id)}
  end

  # callbacks

  # Slackmine.Slack sends message {:message, ...} when a text is recieved from slack
  def handle_info({:message, %{channel: channel, text: text}}, state) do
    @slack_api.typing(channel)

    case parse_issue_ids(text) do
      [] -> {:noreply, state}
      issue_ids -> {:noreply, get_issues(issue_ids, channel, state)}
    end
  end

  # Slackmine.Redmine sends message {:issue, %Issue{}} when issue is
  # retrieved from redmine
  def handle_info({:issue, issue}, state) do
    slack_issue(issue.id, issue, state)
  end

  def handle_info({:issue_failed, id}, state) do
    slack_issue(id, "Could not get info on issue #{id}, sorry.", state)
  end
  def handle_info({:issue_failed, id, reason}, state) do
    slack_issue(id, "Could not get info on issue #{id} because of #{reason}.", state)
  end
end
