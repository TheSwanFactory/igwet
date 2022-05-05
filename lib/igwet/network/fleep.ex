defmodule Igwet.Network.Fleep do
  @moduledoc """
  Wrappers and helpers for calling Fleep APIs
  """
  # require IEx; #IEx.pry
  require Logger
  alias Igwet.Network

  @host "https://fleep.io/"
  @login "api/account/login"
  @conv_sync "api/conversation/sync"
  @headers ["Content-Type": "application/json; charset=utf-8", "Connection": "Keep-Alive"]

# https://elixirforum.com/t/how-to-make-a-multipart-http-request-using-finch/36217

  defp tranform_headers([]), do: []
  defp tranform_headers(headers) do
    headers
    |> Enum.map(fn({k, v}) ->
      {Atom.to_string(k), v}
    end)
  end

  def post(path, body \\ nil) do
    hdr = tranform_headers(@headers)
    {:ok, res} =
      Finch.build(:post, @host <> path, hdr, body)
      |> Finch.request(MyFinch)
    res.body
  end

  def login() do
    user = Application.get_env(:igwet, Igwet.Network.Fleep)[:username]
    pw = Application.get_env(:igwet, Igwet.Network.Fleep)[:password]
    params = %{email: user, password: pw}
    Logger.warn("** login.params: " <> inspect(params))
    {:ok, body} = Jason.encode(params)
    Logger.warn("** login.body: " <> inspect(body))
    result = post(@login, body)
    Logger.warn("** login.result: " <> inspect(result))
    result
  end
end
