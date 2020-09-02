defmodule Igwet.NetworkTest.Factory do
  use Igwet.DataCase
  doctest Igwet.Network.Factory

  alias Igwet.Network

  describe "factory" do
    test "IGWET has its own key" do
      node = Network.get_first_node!(:name, "IGWET")
      assert "com.igwet" == node.key
      assert NaiveDateTime.compare(~N[2018-02-06 00:00:00], node.date) == :eq
    end
  end
end
