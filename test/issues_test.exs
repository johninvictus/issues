defmodule IssuesTest do
  use ExUnit.Case
  import Issues.CLI, only: [parse_args: 1]

  test "help will be returned if provided with -h or --help" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values given if they are given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "three values given if they are given two" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "nothing valid given" do
    assert parse_args(["value"]) == :help
  end
end
