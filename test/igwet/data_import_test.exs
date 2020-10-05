defmodule Igwet.NetworkTest.DataImport do
  require Logger
  use Igwet.DataCase
  alias Igwet.DataImport
  doctest Igwet.DataImport
  alias Igwet.Network

  @test_csv "ingest-test.csv"
  @csv_path Path.absname(@test_csv, "test/support")

  @prior_attrs %{
    email: "exists@example.com",
    key: "prior.key",
    name: "exists",
  }

  @group_attrs %{
    key: "group.key",
    name: "group",
  }

  test "csv_map" do
    map = DataImport.csv_map(@csv_path)
    #Logger.warn "csv_map.map:\n" <> inspect(map)
    assert !is_nil map
    assert length(map) == 7
  end

  test "upsert_on_email exists" do
    {:ok, exists}  = Network.create_node @prior_attrs
    attrs = %{name: "new", key: "new.key", email: @prior_attrs.email, index: 1, parent: 2}
    DataImport.upsert_on_email(attrs)
    updated = Network.get_node!(exists.id)
    assert !is_nil updated
    assert updated.name == attrs.name
  end

  test "upsert_on_email missing" do
    {:ok, exists}  = Network.create_node @prior_attrs
    attrs = %{name: "new", key: "new.key", email: "invalid@example.com", index: 1, parent: 2}
    DataImport.upsert_on_email(attrs)
    result = Network.get_node!(exists.id)
    assert !is_nil result
    assert result.name == @prior_attrs.name
  end

  test "csv_for_group" do
    {:ok, group}  = Network.create_node @group_attrs
    nodes = DataImport.csv_for_group(@csv_path, group)
    assert !is_nil nodes
    assert length(nodes) == 7
    for node <- nodes do
      assert !is_nil node
      assert !is_nil node.meta
      assert !is_nil node.meta.parent_id
      Logger.warn "csv_for_group.entry: #{node.type} #{node.name} #{node.key} #{node.meta.parent_id}"
    end
    assert Enum.at(nodes, 0).meta.parent_id == group.id
    assert Enum.at(nodes, 1).meta.parent_id == Enum.at(nodes, 0).id
    assert Enum.at(nodes, 6).meta.parent_id == Enum.at(nodes, 5).id

  end

end
