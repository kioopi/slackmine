defmodule Slackmine.Redmine.User do
  defstruct(
   id: nil,
   name: nil,
   mail: "",
   login: "",
   firstname: nil,
   lastname: nil
  )

  def list_from_json_string(str) do
    Poison.decode!(str, as: %{"users" => [%Slackmine.Redmine.User{}]}) |>
    Map.get("users")
  end
end

defimpl String.Chars, for: Slackmine.Redmine.User do
  def to_string(%Slackmine.Redmine.User{name: name}) when is_binary(name), do: name
  def to_string(%Slackmine.Redmine.User{firstname: fname, lastname: lname}) do
    String.trim("#{fname} #{lname}")
  end
end
