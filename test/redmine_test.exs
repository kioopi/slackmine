defmodule RedmineTest do
  use ExUnit.Case
  doctest Slackmine.Redmine

  defmodule FakeRedmineClient do
    @behaviour Slackmine.Redmine.Data

    def get_issue(id) do
      case id do
        :good -> {:ok, Slackmine.Redmine.Issue.example}
        :bad -> {:error}
      end
    end

    def get_users(term) do
      case term do
        :good -> {:ok, [%Slackmine.Redmine.User{}]}
        :bad -> {:error}
      end
    end
  end

  test "issue sends the issue to pid when successfull" do
    Slackmine.Redmine.issue(self(), :good, FakeRedmineClient)

    issue = Slackmine.Redmine.Issue.example
    assert_receive({:issue, ^issue})
  end

  test "issue sends issue id to pid when unsuccessfull" do
    Slackmine.Redmine.issue(self(), :bad, FakeRedmineClient)
    assert_receive({:issue_failed, :bad})
  end

  test "users sends the found users to pid when successfull" do
    Slackmine.Redmine.users(self(), :good, FakeRedmineClient)

    user = %Slackmine.Redmine.User{}
    assert_receive({:users, [^user]})
  end
end
