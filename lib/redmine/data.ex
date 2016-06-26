defmodule Slackmine.Redmine.Data do
  use HTTPotion.Base
  alias Slackmine.Redmine.Issue
  alias Slackmine.Redmine.User

  @key Application.get_env(:slackmine, Slackmine.Redmine)[:key]
  @host Application.get_env(:slackmine, Slackmine.Redmine)[:host]

  @callback get_issue(id :: String.t) :: {}
  def get_issue(id) do
    getmine("/issues/#{id}.json", &Issue.from_json_string/1)
  end

  @callback get_users(name :: String.t) :: {}
  def get_users(name) do
    getmine("/users.json?name=#{name}", fn(body) -> User.list_from_json_string(body) end)
  end

  def getmine(url, parse_body) do
    case get(url) do
      %HTTPotion.Response{status_code: 200, body: body} -> {:ok, parse_body.(body) }
      %HTTPotion.Response{status_code: code} -> {:error, "Request failed: #{code}"}
      _ -> {:error}
    end
  end

  def process_url(url) do
    "#{@host}" <> url
  end

  def process_request_headers(headers) do
    Dict.merge(headers, %{
      "Accept": "application/json",
      "X-Redmine-API-Key": @key
    })
  end
end
