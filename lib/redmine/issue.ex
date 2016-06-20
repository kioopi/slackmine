defmodule Slackmine.Redmine.User do
  defstruct [:id, :name]
end

defmodule Slackmine.Redmine.SelectItem do
  defstruct [:id, :name]
end

defmodule Slackmine.Redmine.Issue do
  alias Slackmine.Redmine

  @host Application.get_env(:slackmine, Slackmine.Redmine)[:host]

  defstruct(
    author: %Redmine.User{},
    assigned_to: %Redmine.User{},
    status: %Redmine.SelectItem{},
    priority: %Redmine.SelectItem{},
    created_on: "",
    subject: "",
    description: "",
    id: nil,
    link: ""
  )

  def add_link(%Slackmine.Redmine.Issue{id: id} = issue) do
    Map.put(issue, :link, "#{@host}/issues/#{id}")
  end

  def from_json_string(str) do
    Poison.decode!(str, as: %{"issue" => %Slackmine.Redmine.Issue{}}) |>
    Map.get("issue") |>
    Slackmine.Redmine.Issue.add_link
  end
end

# Implement Chars Protocol so that Issue can be uses with
# to_string(issue) and string interpolations "#{issue}"
# http://elixir-lang.org/docs/stable/elixir/String.Chars.html
defimpl String.Chars, for: Slackmine.Redmine.Issue do
  def to_string(issue) do
    "#{issue.subject}: #{issue.status.name}. -> #{issue.link}"
  end
end
