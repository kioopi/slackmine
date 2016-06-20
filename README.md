# Slackmine

[![Build Status](https://travis-ci.org/kioopi/slackmine.svg?branch=master)](https://travis-ci.org/kioopi/slackmine)

A bot to access information about Redmine issues from Slack.

It parses Redmine issue IDs in Slack messages and answers with basic info about the ticket.

*This is mostly a way for me to play with Elixir. Please don't assume production quality*

## Development

1. Install dependencies

        $ mix deps.get


2. Create `config/secrets.exs` and edit.

        $ cp config/secrets.exs.example config/secrets.exs

3. Start via iex

        $ iex -S mix

Slackmine should now show up in your Slack-Team.

## Running tests

     $ mix test
