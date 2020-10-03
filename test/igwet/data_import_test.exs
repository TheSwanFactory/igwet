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

  test "csv_map" do
    map = DataImport.csv_map(@csv_path)
    #Logger.warn "csv_map.map:\n" <> inspect(map)
    assert !is_nil map
    assert length(map) == 7
  end

  test "upsert_nodes" do
    exists = Network.create_node @prior_attrs
    assert !is_nil exists
  end
end
