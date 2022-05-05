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

  def post(path, params \\ %{}) do
    hdr = tranform_headers(@headers)
    {:ok, body} = Jason.encode(params)
    {:ok, res} =
      Finch.build(:post, @host <> path, hdr, body)
      |> Finch.request(MyFinch)
    {:ok, json} = Jason.decode(res.body)
    json
  end

  def login() do
    user = Application.get_env(:igwet, Igwet.Network.Fleep)[:username]
    pw = Application.get_env(:igwet, Igwet.Network.Fleep)[:password]
    params = %{email: user, password: pw}
    result = post(@login, params)
    #Logger.warn("** login.result: " <> inspect(result))
    result
  end

  def ticket() do
    result = login()
    Map.get(result, "ticket")
  end

  def sync(_conv) do
    @conv_sync
  end
end
