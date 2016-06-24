use Mix.Config

config(:slackmine, Slackmine.Slack, redmine_api: Slackmine.Redmine.Test)
config(:slackmine, Slackmine.Slack, slack_api: Slackmine.Slack.Mock)
