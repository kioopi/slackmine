# Slackmine

A bot to access information about Redmine issues from Slack.

It parses Redmine issue IDs in Slack messages and anwers with basic info about the ticket.

*This is mostly a way for me to play with Elixir. Please don't assume production quality*

## Development

  1. Install dependencies

     $ mix deps.get

  2. Edit `config/config.exs`

  3. Create `config/secrets.exs` and edit.

     $ cp config/secrets.exs.example config/secrets.exs

  4. Start via iex

     $ iex -S mix

## Running tests

     $ mix test
