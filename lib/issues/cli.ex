defmodule Issues.CLI do
  @default_count 4
  alias Issues.GithubIssues

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """
  def main(argv) do
    argv
     |> parse_args
     |> process

  end

  @doc """
  `argv` can be -h or --help, which returns :help.
Otherwise it is a github user name, project name, and (optionally)
the number of entries to format.
Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                aliases: [h: :help])

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [user, project, count], _} ->
        {user, project, String.to_integer(count)}

      {_, [user, project], _} ->
        {user, project, @default_count}

      _ ->
        :help

    end
  end

  def process(:help) do
    IO.puts """
      usage: issues <user> <project> [ count | #{@default_count} ]
    """
  end

  def process({user, project, count}) do
    GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> screen_print
  end

  def decode_response({:client_error, reason}) do
    IO.puts "Error #{reason}"
    System.halt(2)
  end

  def decode_response({:ok, response}), do: response

  def decode_response({:error, reason}) do
    IO.puts "Error #{reason["message"]}"
    System.halt(2)
  end

  def sort_into_ascending_order(json) do
    json
    |> Enum.sort(fn(i1, i2) -> i1["created_at"] <= i2["created_at"]
          end)

  end

  def screen_print(decoded_json) do
     decoded_json
     |>  Enum.each(fn v ->
       [:blue, :bright, "[-]", :white, :bright, " #{ v["title"]}"]
       |> IO.ANSI.format
       |> IO.puts
     end)
  end
end
