defmodule Igwet.NetworkTest.Fleep do
  use Igwet.DataCase
  doctest Igwet.Network.Fleep

  alias Igwet.Network.Fleep

  describe "Fleep" do
    test "Finch request" do
      data = Finch.build(:get, "https://hex.pm") |> Finch.request(MyFinch)
      assert data
    end
  end

end
