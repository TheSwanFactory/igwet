defmodule Igwet.Network.Fleep do
  @moduledoc """
  Wrappers and helpers for calling Fleep APIs
  """
  # require IEx; #IEx.pry
  require Logger
  import Ecto.Query, warn: false
  alias Igwet.Cache
  alias Igwet.Network
  alias Igwet.Repo

  @host "https://fleep.io/"
  @login "api/account/login"
  @conv_sync "api/conversation/sync/"
  @headers ["Content-Type": "application/json; charset=utf-8", "Connection": "Keep-Alive"]
  @fleep_cache :fleep

  @fleep_conv "fleet.conv"
  @fleep_msg "fleet.msg"
  @timezone "US/Pacific"

  #@msg_keys ["account_id", "conversation_id", "message_id", "message", "posted_time"]

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

  def msg_sync(conv) do
    sync(conv)
    |> Map.get("stream")
    |> Enum.filter(fn m -> Map.has_key?(m, "message_id") end)
    #|> Enum.filter(fn m -> msg_obtain(m) end)
  end

  def msg_node(msg) do
    text = msg["message"]
    msg_key = @fleep_msg <> "+" <> msg["message_id"]
    conv_key = @fleep_conv <> "+" <> msg["conversation_id"]
    {:ok, datetime} = DateTime.from_unix(msg["posted_time"], :millisecond)
    {:ok, message} = Network.create_node %{
      about: text,
      date: datetime,
      key: msg_key,
      name: "{datetime}: {msg_key}",
      size: String.length(text),
      type: @fleep_msg
    }
    conv = Network.get_first_node!(:key, conv_key)
    Network.set_node_in_group(message, conv)
    message
  end

  def msg_obtain(msg) do
    msg_key = @fleep_msg <> "+" <> msg["message_id"]
    query = Network.Node |> where([n], n.key == ^msg_key)
    message = Repo.one(query)
    if message, do: message, else: msg_node(msg)
  end

  def make_conv(title, conv_id, email) do
    {:ok, datetime} = DateTime.now(@timezone)
    {:ok, conv} = Network.create_node %{
      about: "Conversation {conv_id} for {email}",
      date: datetime,
      email: email,
      key: @fleep_conv <> "+" <> conv_id,
      name: title,
      timezone: @timezone,
      type: @fleep_conv,
    }
    conv
  end
end
