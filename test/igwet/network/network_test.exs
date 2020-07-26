defmodule Igwet.NetworkTest do
  use Igwet.DataCase
  alias Igwet.Network
  # doctest Igwet.Network

  setup do
    admin_name = Application.get_env(:igwet, :admin_user)

    {
      :ok,
      in: Network.get_first_node!(:name, "in"),
      igwet_group: Network.get_first_node!(:name, "IGWET"),
      admin_group: Network.get_first_node!(:name, "admin"),
      admin_node: Network.get_first_node!(:name, admin_name),
      admin_name: admin_name,
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

    test "edge_exists?", context do
      user = context[:admin_node]
      is_in = context[:in]
      group = context[:admin_group]
      assert Network.edge_exists?(user, is_in, group)
      assert !Network.edge_exists?(group, is_in, user)
    end

    test "objects_for_predicate", context do
      groups = Network.objects_for_predicate("in")
      assert Enum.count(groups) == 2

      first = List.first(groups)
      assert first.name == context[:igwet_group].name
    end

    test "subjects_for_predicate", context do
      groups = Network.subjects_for_predicate("in")
      assert Enum.count(groups) == 2

      first = List.first(groups)
      assert first.name == context[:admin_group].name
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
  end
end
