defmodule Slackmine do
  use Application

  @slack_api Application.get_env(:slackmine, Slackmine.Slack)[:slack_api]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(@slack_api, [Slackmine.Slack, Slackmine.Bot]),
      worker(Slackmine.Bot, [Slackmine.Bot, Slackmine.Slack]),
      worker(Slackmine.Users, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Slackmine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
