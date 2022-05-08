defmodule Igwet.NetworkTest.Fleep do
  require Logger
  use Igwet.DataCase
  doctest Igwet.Network.Fleep
  alias Igwet.Network
  alias Igwet.Network.Fleep

  @timezone "US/Pacific"
  @test_conv "ab0b7436-05b0-4a0f-b414-3f5073757078"
  @test_email "test@fleep.io"
  @test_msg %{
    "account_id" => "10d292e3-359d-431e-8ed2-72023ef1a186",
    "conversation_id" => "ab0b7436-05b0-4a0f-b414-3f5073757078",
    "message" => "<msg><p>i belive in that too<br/>",
    "message_id" => "a5899301-4f47-40e2-bb8a-923c51757078",
    "posted_time" => 1629051100,
    "mail_hdrs" => [
      %{ "prefix" => "From", "addresses" => [%{"addr" => "ernest.bruce@fleep.io"}]},
      %{ "prefix" => "To", "addresses" => [%{"addr" => "drernie@fleep.io"}]}
    ]
  }

  def create_conv() do
    Fleep.make_conv("fleep_test", @test_conv, @test_email)
  end

  describe "Fleep" do
    test "Finch request" do
      data = Finch.build(:get, "https://hex.pm") |> Finch.request(MyFinch)
      assert data
    end

    test "Finch post" do
      {:ok, res} =
        Finch.build(:post, "https://postman-echo.com/post", [], "raw")
        |> Finch.request(MyFinch)
      json = Jason.decode!(res.body)
      assert json["data"] == "raw"
    end

    test "config" do
      user = Application.get_env(:igwet, Igwet.Network.Fleep)[:username]
      assert user
      pw = Application.get_env(:igwet, Igwet.Network.Fleep)[:password]
      assert pw
    end

    test "login" do
      json = Fleep.login()
      assert Map.has_key?(json, "ticket")
      assert Map.has_key?(json, "set-cookie")
    end

    test "auth_params" do
      params = Fleep.auth_params()
      assert Map.has_key?(params, :ticket)
    end

    test "sync" do
      json = Fleep.sync(@test_conv)
      assert Map.has_key?(json, "stream")
      stream = json["stream"]
      last = List.last(stream)
      assert last
      #Logger.warn(last)
    end

    @tag :skip
    test "msg_sync" do
      c = create_conv()
      {:ok, now} = DateTime.now(@timezone)
      assert c.date < now
      assert c.size == 0
      n = c.size

      m = Fleep.msg_sync(@test_conv)
      assert c.date > now
      assert c.size > 1
      assert c.size >= n

      assert Kernel.length(m) > 0
      first = Enum.at(m, 0)
      assert first
    end

    test "make_conv" do
      c = create_conv()
      assert c
      assert c.id
      assert @test_email == c.email
      assert c.key =~ @test_conv

      conv = Network.get_first_node!(:about, @test_conv)
      assert conv
    end

    test "msg_node" do
      create_conv()
      m = Fleep.msg_node(@test_msg)
      assert m
      assert m.key =~ @test_msg["message_id"]
      assert m.name =~ "ernest"
    end

    test "msg_from" do
      create_conv()
      m = Fleep.msg_from(@test_msg)
      assert m
      assert m =~ "ernest"
    end

    test "msg_obtain" do
      create_conv()
      m = Fleep.msg_obtain(@test_msg)
      assert m
      n = Fleep.msg_obtain(@test_msg)
      assert m === n
    end
  end
end
