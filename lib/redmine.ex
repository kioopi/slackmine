defmodule Slackmine.Redmine do
  alias Slackmine.Redmine.Data

  @callback issue(from :: pid, id :: String.t) :: {:ok, pid}
  @doc """
  Starts get_issue_data/2 as an async Task to fetch data from Redmine passing it the pid to send the result to and the issue ID in question.
  """
  def issue(from, id) do
    Task.start(__MODULE__, :get_issue_data, [from, id])
  end

  def get_issue_data(from, id) do
    case Data.get_issue(id) do
      {:ok, issue} -> send_issue(issue, from)
      {:error, reason} -> send_issue_failed(id, reason, from)
      _ -> send_issue_failed(id, from)
		end
  end

  def send_issue(issue, pid), do: send(pid, {:issue, issue})

  def send_issue_failed(id, pid), do: send(pid, {:issue_failed, id})
  def send_issue_failed(id, reason, pid), do: send(pid, {:issue_failed, id, reason})

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
    send(from, {:issue, %Issue{
       author: %User{id: 173, name: "The Author"},
       created_on: "2016-03-16T10:55:14Z",
       description: "Description Text of the issue\r\n",
       id: 12345,
       link: "https://redmine.codevise.de/issues/12345",
       priority: %SelectItem{id: 4, name: "Normal"},
       status: %SelectItem{id: 3, name: "Resolved"},
       subject: "Title of the issue"}
   })
  end
end
