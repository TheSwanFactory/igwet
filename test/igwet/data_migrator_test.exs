defmodule Igwet.NetworkTest.DataMigrator do
  require Logger
  use Igwet.DataCase
  alias Igwet.DataMigrator
  alias Igwet.Network

  @bare_attrs %{
    about: "some about",
    key: "some.key",
    name: "some name",
  }

  describe "migrating relationships" do
    setup [:create_event]

    test "before", %{node: node, event: event, p_for: p_for} do
      assert is_nil node.type
      edge = Network.find_edge(event, p_for, node)
      assert !is_nil edge
      assert is_nil edge.relation
    end

    test "after", %{node: node, event: event, p_for: p_for} do
      old_type = Network.get_type_edge(node)
      DataMigrator.run()
      node2 = Network.get_node!(node.id)
      assert !is_nil node2.type
      assert old_type == node2.type
      assert is_nil Network.get_type_edge(node)

      edge = Network.find_edge(event, p_for, node)
      assert !is_nil edge
      assert "for" == edge.relation
    end
  end

  defp create_event(_) do
    p_type = Network.get_predicate("type")
    p_group = Network.get_predicate("group")
    p_event = Network.get_predicate("event")
    p_for = Network.get_predicate("for")
    {:ok, group} = Network.create_node(@bare_attrs)
    {:ok, event} = Network.create_node %{
      name: "event name",
      meta: %{duration: 90, parent_id: group.id, recurrence: 7},
      key: "event.key",
    }
    _edge_group = Network.create_edge(%{subject_id: group.id, predicate_id: p_type.id, object_id: p_group.id})
    _edge_event = Network.create_edge(%{subject_id: event.id, predicate_id: p_type.id, object_id: p_event.id})
    _edge_for = Network.create_edge(%{subject_id: event.id, predicate_id: p_for.id, object_id: group.id})
    %{node: group, event: event, p_for: p_for}
  end
end
