defmodule Igwet.NetworkTest do
  use Igwet.DataCase

  alias Igwet.Network

  describe "nodes" do
    alias Igwet.Network.Node

    @valid_attrs %{about: "some about", email: "some email", key: "some key", name: "some name", phone: "some phone"}
    @update_attrs %{about: "some updated about", email: "some updated email", key: "some updated key", name: "some updated name", phone: "some updated phone"}
    @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil}

    def node_fixture(attrs \\ %{}) do
      {:ok, node} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_node()

      node
    end

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Network.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Network.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      assert {:ok, %Node{} = node} = Network.create_node(@valid_attrs)
      assert node.about == "some about"
      assert node.email == "some email"
      assert node.key == "some key"
      assert node.name == "some name"
      assert node.phone == "some phone"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      assert {:ok, node} = Network.update_node(node, @update_attrs)
      assert %Node{} = node
      assert node.about == "some updated about"
      assert node.email == "some updated email"
      assert node.key == "some updated key"
      assert node.name == "some updated name"
      assert node.phone == "some updated phone"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_node(node, @invalid_attrs)
      assert node == Network.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Network.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Network.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Network.change_node(node)
    end
  end

  describe "edges" do
    alias Igwet.Network.Edge

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def edge_fixture(attrs \\ %{}) do
      {:ok, edge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_edge()

      edge
    end

    test "list_edges/0 returns all edges" do
      edge = edge_fixture()
      assert Network.list_edges() == [edge]
    end

    test "get_edge!/1 returns the edge with given id" do
      edge = edge_fixture()
      assert Network.get_edge!(edge.id) == edge
    end

    test "create_edge/1 with valid data creates a edge" do
      assert {:ok, %Edge{} = edge} = Network.create_edge(@valid_attrs)
    end

    test "create_edge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_edge(@invalid_attrs)
    end

    test "update_edge/2 with valid data updates the edge" do
      edge = edge_fixture()
      assert {:ok, edge} = Network.update_edge(edge, @update_attrs)
      assert %Edge{} = edge
    end

    test "update_edge/2 with invalid data returns error changeset" do
      edge = edge_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_edge(edge, @invalid_attrs)
      assert edge == Network.get_edge!(edge.id)
    end

    test "delete_edge/1 deletes the edge" do
      edge = edge_fixture()
      assert {:ok, %Edge{}} = Network.delete_edge(edge)
      assert_raise Ecto.NoResultsError, fn -> Network.get_edge!(edge.id) end
    end

    test "change_edge/1 returns a edge changeset" do
      edge = edge_fixture()
      assert %Ecto.Changeset{} = Network.change_edge(edge)
    end
  end

  describe "addresses" do
    alias Igwet.Network.Address

    @valid_attrs %{city: "some city", city_district: "some city_district", country: "some country", country_region: "some country_region", entrance: "some entrance", house_number: "some house_number", island: "some island", level: "some level", name: "some name", postcode: "some postcode", road: "some road", staircase: "some staircase", state: "some state", state_district: "some state_district", suburb: "some suburb", unit: "some unit", world_region: "some world_region"}
    @update_attrs %{city: "some updated city", city_district: "some updated city_district", country: "some updated country", country_region: "some updated country_region", entrance: "some updated entrance", house_number: "some updated house_number", island: "some updated island", level: "some updated level", name: "some updated name", postcode: "some updated postcode", road: "some updated road", staircase: "some updated staircase", state: "some updated state", state_district: "some updated state_district", suburb: "some updated suburb", unit: "some updated unit", world_region: "some updated world_region"}
    @invalid_attrs %{city: nil, city_district: nil, country: nil, country_region: nil, entrance: nil, house_number: nil, island: nil, level: nil, name: nil, postcode: nil, road: nil, staircase: nil, state: nil, state_district: nil, suburb: nil, unit: nil, world_region: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Network.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Network.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Network.create_address(@valid_attrs)
      assert address.city == "some city"
      assert address.city_district == "some city_district"
      assert address.country == "some country"
      assert address.country_region == "some country_region"
      assert address.entrance == "some entrance"
      assert address.house_number == "some house_number"
      assert address.island == "some island"
      assert address.level == "some level"
      assert address.name == "some name"
      assert address.postcode == "some postcode"
      assert address.road == "some road"
      assert address.staircase == "some staircase"
      assert address.state == "some state"
      assert address.state_district == "some state_district"
      assert address.suburb == "some suburb"
      assert address.unit == "some unit"
      assert address.world_region == "some world_region"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, address} = Network.update_address(address, @update_attrs)
      assert %Address{} = address
      assert address.city == "some updated city"
      assert address.city_district == "some updated city_district"
      assert address.country == "some updated country"
      assert address.country_region == "some updated country_region"
      assert address.entrance == "some updated entrance"
      assert address.house_number == "some updated house_number"
      assert address.island == "some updated island"
      assert address.level == "some updated level"
      assert address.name == "some updated name"
      assert address.postcode == "some updated postcode"
      assert address.road == "some updated road"
      assert address.staircase == "some updated staircase"
      assert address.state == "some updated state"
      assert address.state_district == "some updated state_district"
      assert address.suburb == "some updated suburb"
      assert address.unit == "some updated unit"
      assert address.world_region == "some updated world_region"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_address(address, @invalid_attrs)
      assert address == Network.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Network.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Network.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Network.change_address(address)
    end
  end
end
