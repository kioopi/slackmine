defmodule Slackmine.Users do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add(sl_user, rm_user) do
    Agent.update(__MODULE__, fn(users) -> Map.put(users, sl_user, rm_user) end)
  end

  def get(sl_user) do
    Agent.get(__MODULE__, fn(users) -> Map.fetch(users, sl_user) end)
  end
end
