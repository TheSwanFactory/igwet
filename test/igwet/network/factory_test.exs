defmodule Igwet.NetworkTest.Factory do
  use Igwet.DataCase
  doctest Igwet.Network.Factory

  alias Igwet.Network

  describe "factory" do
    test "IGWET has its own key" do
      node = Network.get_first_node_named!("IGWET")
      assert "com.igwet" == node.key

      {:ok, datetime, 0} = DateTime.from_iso8601("2018-02-06T00:00:00Z")
      assert DateTime.compare(datetime, node.date) == :eq
    end
  end
end
