defmodule Igwet.NetworkTest.Factory do
  use Igwet.DataCase
  doctest Igwet.Network.Factory

  alias Igwet.Network

  describe "factory" do
    test "IGWET has its own key" do
      node = Network.get_first_node_named!("IGWET")
      assert node.key == "com.igwet"
    end

  end
end
