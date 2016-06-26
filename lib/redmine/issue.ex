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

  def example do
    %Slackmine.Redmine.Issue{
      author: %Redmine.User{id: 173, name: "The Author"},
      created_on: "2016-03-16T10:55:14Z",
      description: "Description Text of the issue\r\n",
      id: 12345,
      link: "https://redmine.codevise.de/issues/12345",
      priority: %Redmine.SelectItem{id: 4, name: "Normal"},
      status: %Redmine.SelectItem{id: 3, name: "Resolved"},
      subject: "Title of the issue"
    }
  end
end

# Implement Chars Protocol so that Issue can be uses with
# to_string(issue) and string interpolations "#{issue}"
# http://elixir-lang.org/docs/stable/elixir/String.Chars.html
defimpl String.Chars, for: Slackmine.Redmine.Issue do
  def to_string(issue) do
    "#{issue.subject} (#{issue.author.name}): #{issue.status.name}. -> #{issue.link}"
  end
end
