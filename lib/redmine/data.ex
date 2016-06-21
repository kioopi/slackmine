defmodule Slackmine.Redmine.Data do
  use HTTPotion.Base
  alias Slackmine.Redmine.Issue

  @key Application.get_env(:slackmine, Slackmine.Redmine)[:key]
  @host Application.get_env(:slackmine, Slackmine.Redmine)[:host]

  @callback get_issue(id :: String.t) :: {}
  def get_issue(id) do
    case get("/issues/#{id}.json") do
      %HTTPotion.Response{status_code: 200, body: body} -> {:ok, Issue.from_json_string(body)}
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
