defmodule Igwet.NetworkTest do
  use Igwet.DataCase
  alias Igwet.Network
  #doctest Igwet.Network

  describe "seeds" do

    test "seed_node" do
      keys = Application.get_env(:igwet, :seed_keys)
      user = Network.seed_node(:superuser)
      assert user.key == keys[:superuser]
    end

    test "node_is_admin?" do
      user = Network.seed_node(:superuser)
      assert Network.node_is_admin?(user)
    end

    test "node_in_group?" do
      user = Network.seed_node(:superuser)
      group = Network.seed_node(:admin_group)
      assert Network.node_in_group?(user, group)
      assert !Network.node_in_group?(group, user)
    end

    test "edge_exists?" do
      user = Network.seed_node(:superuser)
      member = Network.seed_node(:in)
      group = Network.seed_node(:admin_group)
      assert Network.edge_exists?(user, member, group)
      assert !Network.edge_exists?(group, member, user)
    end

    test "node_groups" do
      user = Network.seed_node(:superuser)
      group = Network.seed_node(:admin_group)
      groups = Network.node_groups(user)
      assert Enum.count(groups) == 1

      first = List.first(groups)
      assert first.name == group.name
    end

    test "node_members" do
      user = Network.seed_node(:superuser)
      group = Network.seed_node(:admin_group)
      members = Network.node_members(group)
      assert Enum.count(members) == 1

      first = List.first(members)
      assert first.name == user.name
    end
  end

end
