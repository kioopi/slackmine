defmodule Slackmine.Redmine do
  @moduledoc """
  Fetches information about Redmine issues via http and sends them back to a process.
  """
  @callback issue(from :: pid, id :: String.t) :: {:ok, pid}
  @doc """
  Starts get_issue_data/2 as an async Task to fetch data from Redmine passing it the pid to send the result to and the issue ID in question.
  """
  def issue(from, id, client\\Slackmine.Redmine.Data) do
    Task.start(__MODULE__, :get_issue_data, [from, id, client])
  end

  def users(from, name, client\\Slackmine.Redmine.Data) do
    Task.start(__MODULE__, :get_users, [from, name, client])
  end

  @doc """
  Uses the data module to get a struct descriping an isssue and passes it on to a
  funcion that informs the pid that requested the issue about success or failure.
  """
  def get_issue_data(from, id, client\\Slackmine.Redmine.Data) do
    client.get_issue(id) |> send_issue(from, id)
  end

  def send_issue({:ok, issue}, pid, _id), do: send(pid, {:issue, issue})
  def send_issue({:error, reason}, pid, id), do: send(pid, {:issue_failed, id, reason})
  def send_issue({:error}, pid, id), do:  send(pid, {:issue_failed, id})

  def get_users(from, name, client\\Slackmine.Redmine.Data) do
    client.get_users(name) |> send_users(from, name)
  end

  # FIXME: cleanup duplication
  def send_users({:ok, users}, pid, _name), do: send(pid, {:users, users})
  def send_users({:error, reason}, pid, name), do: send(pid, {:users_failed, name, reason})
  def send_users({:error}, pid, name), do:  send(pid, {:users_failed, name})

  defmodule CLI do
    @moduledoc """
    To be used for debugging from the interactive shell:

    Example:

       iex> Slackmine.Redmine.CLI.issue(12345)
    """
    def issue(id) do
      Slackmine.Redmine.issue(self(), id)
      receive do
        {:issue, msg} -> IO.inspect msg
      end
    end
  end
end

defmodule Slackmine.Redmine.Test do
  @moduledoc """
  An alternative implementation of the behaviour defined in Slackmine.Slack.

  Used while testing.

  See: http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/

  """
  @behaviour Slackmine.Redmine

  alias Slackmine.Redmine.Issue
  alias Slackmine.Redmine.User
  alias Slackmine.Redmine.SelectItem

  def issue(from, _id) do
    send(from, {:issue, Slackmine.Redmine.Issue.example})
  end
end
