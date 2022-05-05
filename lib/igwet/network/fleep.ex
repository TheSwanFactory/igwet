defmodule Igwet.Network.Fleep do
  @moduledoc """
  Wrappers and helpers for calling Fleep APIs
  """
  # require IEx; #IEx.pry
  require Logger
  alias Igwet.Cache

  @host "https://fleep.io/"
  @login "api/account/login"
  @conv_sync "api/conversation/sync/"
  @headers ["Content-Type": "application/json; charset=utf-8", "Connection": "Keep-Alive"]
  @fleep_cache :fleep

# https://elixirforum.com/t/how-to-make-a-multipart-http-request-using-finch/36217

  defp transform_headers([]), do: []
  defp transform_headers(headers) do
    if Cache.has(@fleep_cache, "set-cookie") do
      headers ++ ["Cookie": Cache.get(@fleep_cache, "set-cookie")]
    else
      headers
    end
    |> Enum.map(
      fn({k, v}) -> {Atom.to_string(k), v}
    end)
  end

  def post(path, params \\ %{}, headers \\ @headers) do
    hdr = transform_headers(headers)
    {:ok, body} = Jason.encode(params)
    #Logger.warn("** post.body: " <> inspect(body))
    {:ok, res} =
      Finch.build(:post, @host <> path, hdr, body)
      |> Finch.request(MyFinch)
    hmap = Enum.into(res.headers, %{})
    #Logger.warn("** post.hmap: " <> inspect(hmap))
    {:ok, json} = Jason.decode(res.body)
    Map.merge(hmap, json)
  end

  defp cache(source, key) do
    source
    |> Map.get(key)
    |> Cache.set(@fleep_cache, key)
  end

  def login() do
    user = Application.get_env(:igwet, Igwet.Network.Fleep)[:username]
    pw = Application.get_env(:igwet, Igwet.Network.Fleep)[:password]
    params = %{email: user, password: pw}
    result = post(@login, params)

    cache(result, "ticket")
    cache(result, "set-cookie")
    result
  end

  def auth_params() do
    login()
    ticket = Cache.get(@fleep_cache, "ticket")
    %{ticket: ticket, api_version: 4}
  end

  def sync(conv) do
    result = post(@conv_sync <> conv, auth_params())
    result
  end
end
