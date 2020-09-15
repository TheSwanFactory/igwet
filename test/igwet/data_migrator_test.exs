defmodule Igwet.NetworkTest.DataMigrator do
  require Logger
  use Igwet.DataCase
  alias Igwet.Network

  @bare_attrs %{
    about: "some about",
    key: "some.key",
    name: "some name",
  }

  describe "migrate relationships inline" do
    setup [:create_event]

    test "fixture nodes lack inlines", %{node: node, event: event} do
      assert node
      assert event
    end

    test "migrated nodes are inline", %{node: node, event: event} do
      assert node
      assert event
    end
  end

  defp create_event(_) do
    p_type = Network.get_predicate("type")
    p_group = Network.get_predicate("group")
    p_event = Network.get_predicate("event")
    p_for = Network.get_predicate("for")
    {:ok, group} = Network.create_node(@bare_attrs)
    event = Network.create_node %{
      name: "event name",
      meta: %{duration: 90, parent_id: group.id, recurrence: 7},
      key: "event.key",
    }
    _edge_group = Network.create_edge(%{subject_id: group.id, predicate_id: p_type.id, object_id: p_group.id})
    _edge_event = Network.create_edge(%{subject_id: event.id, predicate_id: p_type.id, object_id: p_event.id})
    _edge_for = Network.create_edge(%{subject_id: event.id, predicate_id: p_for.id, object_id: group.id})
    %{node: group, event: event}
  end
end
