defmodule Issues.GithubIssues do
  @user_agent [{"User-agent", "Elixir invictusnitude@gmail.com"}]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
    
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({:error, _ }) do
    {:client_error, "check your internet connection and try later"}
  end

  def handle_response({:ok, %HTTPoison.Response{body: body,  status_code: 200}}) do
    result =
    body
    |> JSON.decode!

    {:ok, result}
  end

  def handle_response({:ok, %HTTPoison.Response{body: body,  status_code: _}}) do
    {:error, body |> JSON.decode!}
  end
end
