defmodule Slackmine.Channel do
  def start_link do
    Agent.start_link(fn -> %{
      issues: []
    } end)
  end

  def get(channel, key) do
    Agent.get(channel,  &Map.get(&1, key))
  end

  def put(channel, key, value) do
    Agent.update(channel, &Map.put(&1, key, value))
  end

  def delete(channel, key) do
    Agent.get_and_update(channel, &Map.pop(&1, key))
  end

  def get_issues(channel) do
    get(channel, :issues)
  end

  def add_issue(channel, issue) do
    Agent.update(channel, fn(context) -> Map.update(context, :issues, [], &([issue|&1])) end)
  end
end

defmodule Slackmine.Channels do
  use GenServer
  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def get(name) do
    GenServer.call(@name, {:lookup, name})
  end

  ## Server Callbacks

  def init(:ok) do
    channels = %{}
    refs  = %{}
    {:ok, {channels, refs}}
  end

  def handle_call({:lookup, name}, _from, state={channels, refs}) do
    if Map.has_key?(channels, name) do
      {:reply, Map.fetch(channels, name), state}
    else
      {:ok, channel} = Slackmine.Channel.Supervisor.start_channel
      ref = Process.monitor(channel)
      {:reply, {:ok, channel}, {Map.put(channels, name, channel), Map.put(refs, ref, name)}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {channels, refs}) do
    {name, refs} = Map.pop(refs, ref)
    channels = Map.delete(channels, name)
    {:noreply, {channels, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

defmodule Slackmine.Channel.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_channel do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Slackmine.Channel, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
