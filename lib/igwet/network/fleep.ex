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

  def post(path, body \\ nil) do
    {:ok, res} =
      Finch.build(:post, @host <> path, [], body)
      |> Finch.request(MyFinch)
    res.body
  end

  def login() do
    params = {}
    body = post(@login)
    Logger.warn("** login.body: " <> inspect(body))
    body
  end
end
