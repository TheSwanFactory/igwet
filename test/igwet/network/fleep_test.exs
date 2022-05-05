defmodule Igwet.NetworkTest.Fleep do
  use Igwet.DataCase
  doctest Igwet.Network.Fleep

  alias Igwet.Network.Fleep

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

    test "Fleep config" do
      user = Application.get_env(:igwet, Igwet.Network.Fleep)[:username]
      assert user
      pw = Application.get_env(:igwet, Igwet.Network.Fleep)[:password]
      assert pw
    end

    test "Fleep login" do
      body = Fleep.login()
      assert body =~ "ticket"
    end
  end

end
