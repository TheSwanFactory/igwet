defmodule Igwet.NetworkTest.Fleep do
  use Igwet.DataCase
  doctest Igwet.Network.Fleep

  alias Igwet.Network.Fleep
  @test_conv "ab0b7436-05b0-4a0f-b414-3f5073757078"

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

    @tag :skip
    test "sync" do
      json = Fleep.sync(@test_conv)
      assert Map.has_key?(json, "success")
    end
  end

end
