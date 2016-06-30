defmodule Slackmine.Command.Users do
  @behaviour Slackmine.Command

  @rex ~r/user/
  @redmine_api Application.get_env(:slackmine, Slackmine.Slack)[:redmine_api]
  @slack_api Slackmine.Slack

  alias Slackmine.Redmine
  alias Slackmine.Command

  def parse(text) do
    if Regex.match?(@rex, text) do
      {:match, %{term: search_term(text)}}
    else
      :nomatch
    end
  end

  def call(%{term: term}, channel, _user) do
    Redmine.Data.get_users(term) |> Command.post_users(channel)

    Process.exit(self(), :normal)
    {:ok, self()}
  end

  defp search_term(text) do
    term = List.last(String.split(text))
    if Regex.match?(@rex, term), do: "", else: term
  end
end
