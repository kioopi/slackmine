defmodule Slackmine.Mixfile do
  use Mix.Project

  def project do
    [app: :slackmine,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :slack, :httpotion],
     # The project runs Slackmine.start/2 (in lib/slackmine.ex) when starting:
     mod: {Slackmine, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:slack, "~> 0.5.0"},  # Slack Client
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
      {:httpotion, "~> 3.0.0"}, # HTTP Requests
      {:poison, "~> 2.0"} # JSON Parser
    ]
  end
end
