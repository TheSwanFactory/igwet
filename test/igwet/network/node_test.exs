defmodule Igwet.NetworkTest.Node do
  use Igwet.DataCase
  alias Igwet.Network
  doctest Igwet.Network.Node

  describe "nodes" do
    alias Igwet.Network.Node

    @valid_attrs %{
      about: "some about",
      email: "some email",
      key: "some key",
      name: "some name",
      phone: "some phone"
    }
    @update_attrs %{
      about: "next about",
      email: "next email",
      key: "next key",
      name: "next name",
      phone: "next phone"
    }
    @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil}

    def node_fixture(attrs \\ %{}) do
      {:ok, node} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_node()

      node
    end

    test "get_first_node_named!/1 returns first node" do
      node = node_fixture()
      node_fixture(%{key: "different key"})
      assert Network.get_first_node_named!(node.name) == node
    end

    test "get_first_node_named!/1 raises if no node with that name" do
      assert_raise Ecto.NoResultsError, fn -> Network.get_first_node_named!("unnamed") end
    end

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Enum.member?(Network.list_nodes(), node)
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
      assert node.about == "next about"
      assert node.email == "next email"
      assert node.key == "next key"
      assert node.name == "next name"
      assert node.phone == "next phone"
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
end
