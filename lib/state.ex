defmodule Slackmine.Bot.State do
  @moduledoc """
  Slackmine.Slack.State deals with the state map used by the Slackmine.Slack module.

  It is used to keep track which issue-ids where mentioned in which slack-channel.
  When an issue is fetched it can be send to the appropriate channels and taken out of the state again.

  """

  @doc """
  Returns the inital state map.

  FIXME: Should possibly become a struct in this module.
  """
  def initial do
    %{ pending_issues: %{}, 
      channel: nil }  # FIXME channel cant be stored as global context but each channel needs its own context.
  end

  @doc """
  Updates the pending_issues map with an issue-channel pair (or adds a channel if the issue is is allready in the map).
  When the issue is retrieved the channels waiting for it can be informed.

  Returns new state map.
  """
  def mark_issue_as_pending(state, id, channel) do
    %{ state | :pending_issues => Map.update(state.pending_issues, id, [channel], fn(channels) -> [channel|channels] end)}
  end

  @doc """
  Removes issue (and channels) from pending_issues map.

  Returns new state map.
  """
  def remove_pending_issue(state, id) when is_integer(id), do: remove_pending_issue(state, to_string(id))
  def remove_pending_issue(state, id) do
    %{ state | :pending_issues => Map.delete(state.pending_issues, id)}
  end

  @doc """
  Returns list of channel-ids waiting for an issue
  """
  def get_channels_for_pending_issue(state, id) when is_integer(id), do:
  get_channels_for_pending_issue(state, to_string(id))
  def get_channels_for_pending_issue(state, id) do
    state.pending_issues[id]
  end
end
