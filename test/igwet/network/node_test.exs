defmodule Igwet.NetworkTest.Node do
  require Logger
  use Igwet.DataCase
  alias Igwet.Network
  alias Igwet.Network.Node
  doctest Igwet.Network.Node

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

  @event_attrs %{
    name: "event name",
    key: "event.key",
    date: %{year: 2020, month: 4, day: 1, hour: 2, minute: 3},
    timezone: "US/Pacific",
    meta: %{capacity: 2, duration: 90, parent_id: nil, recurrence: 7}
  }

  def node_fixture(attrs \\ %{}) do
    {:ok, node} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Network.create_node()
    node
  end

  describe "get node" do
    test "get_first_node!/1 returns first node" do
      node = node_fixture()
      node_fixture(%{key: "different key"})
      assert Network.get_first_node!(:name, node.name) == node
      assert Network.get_first_node!(:phone, node.phone) == node
    end

    test "get_first_node_named!/1 raises if no node with that name" do
      assert_raise Ecto.NoResultsError, fn -> Network.get_first_node!(:name, "unnamed") end
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
  end

  describe "modify node" do
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

  describe "rsvp node" do
    setup [:create_event]

    test "get_member_for_email/2 gets node if exists", %{node: node, group: group} do
      member = Network.get_member_for_email(node.email, group)
      assert node.phone == member.phone
    end

    test "get_member_for_email/2 creates node if needed", %{group: group} do
      email = "test@example.com"
      member = Network.get_member_for_email(email, group)
  #      Logger.warn inspect(node)
      assert nil != member
      assert email == member.email
      assert "test" == member.name
    end

    test "attend!/2 returns :ok if enough open" do

    end

    test "attend!/2 returns :error if NOT enough open" do
    end

    test "attend!/2 updates count if already exists" do
    end
  end

  defp create_event(_) do
    node = node_fixture()
    group = node_fixture(@update_attrs)
    event = @event_attrs
            |> put_in([:meta, :parent_id], group.id)
            |> node_fixture()
    %{node: node, group: group, event: event}
  end
end
