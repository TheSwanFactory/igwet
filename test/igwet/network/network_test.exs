defmodule Igwet.NetworkTest do
  use Igwet.DataCase
  alias Igwet.Network
  # doctest Igwet.Network

  setup do
    admin_name = Application.get_env(:igwet, :admin_user)
    {:ok, user} =Network.create_node(%{name: "Test Node", key: "test+user"})
    {
      :ok,
      in: Network.get_first_node!(:name, "in"),
      igwet_group: Network.get_first_node!(:name, "IGWET"),
      admin_group: Network.get_first_node!(:name, "admin"),
      admin_node: Network.get_first_node!(:name, admin_name),
      admin_name: admin_name,
      test_node: user,
    }
  end

  describe "seeds" do
    test "node_is_admin?", context do
      assert Network.node_is_admin?(context[:admin_node])
    end

    test "node_in_group?", context do
      assert Network.node_in_group?(context[:admin_node], context[:admin_group])
      assert !Network.node_in_group?(context[:admin_group], context[:admin_node])
    end

    test "find_edge", context do
      user = context[:admin_node]
      group = context[:admin_group]

      assert !is_nil Network.find_edge(user, "in", group)
      assert nil == Network.find_edge(group, "in", user)
    end

    test "objects_for_predicate", context do
      groups = Network.objects_for_predicate("in")
      assert Enum.count(groups) == 2

      groups
      |> Enum.map(& &1.name)
      |> Enum.member?(context[:igwet_group].name)
    end

    test "subjects_for_predicate", context do
      groups = Network.subjects_for_predicate("in")
      assert Enum.count(groups) == 2

      groups
      |> Enum.map(& &1.name)
      |> Enum.member?(context[:admin_group].name)
    end

    test "node_groups", context do
      groups = Network.node_groups(context[:admin_node])
      assert Enum.count(groups) == 1

      first = List.first(groups)
      assert first.name == context[:admin_group].name
    end

    test "node_members", context do
      members = Network.node_members(context[:admin_group])
      assert Enum.count(members) == 1

      first = List.first(members)
      assert first.name == context[:admin_node].name
    end

    test "get_initials", context do
      user = context[:test_node]
      assert is_nil user.initials
      assert Network.get_initials(user) == "tn"
      assert Network.get_node!(user.id).initials == "tn"
    end

    test "get_predicate", _context do
      node = Network.get_predicate("of")
      assert !is_nil node
      assert Network.get_predicate("of") == node
    end

    test "set_node_in_group", context do
      node = context[:test_node]
      group = context[:admin_group]
      Network.set_node_in_group(node, group)
      assert Network.node_in_group?(node, group)
    end

    test "unset_node_in_group", context do
      node = context[:test_node]
      group = context[:admin_group]
      Network.set_node_in_group(node, group)
      Network.unset_node_in_group(node, group)
      assert !Network.node_in_group?(node, group)
    end

  end
end
