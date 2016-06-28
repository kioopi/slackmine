defmodule CommandTest do
  use ExUnit.Case
  alias Slackmine.Command
  doctest Slackmine.Command

  test "nl_join returns string" do
    assert Command.nl_join(["john-paul", "george", "ringo"]) == "john-paul, george and ringo"
    assert Command.nl_join(["tick", 2, "track"], "und") == "tick, 2 und track"
    assert Command.nl_join(["left", "right"], "or") == "left or right"
  end
end
