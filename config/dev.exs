use Mix.Config

config(:slackmine, Slackmine.Slack, redmine_api: Slackmine.Redmine)
config(:slackmine, Slackmine.Slack, slack_api: Slackmine.Slack.WithName)

import_config "secrets.exs"
