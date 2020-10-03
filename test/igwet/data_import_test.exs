defmodule Igwet.NetworkTest.DataImport do
  require Logger
  use Igwet.DataCase
  alias Igwet.DataImport
  doctest Igwet.DataImport
  #alias Igwet.Network

  @test_csv "ingest-test.csv"
  #@test_dir Application.app_dir(:igwet, "../..")
  @csv_path Path.absname(@test_csv, "test/support")

  test "csv_map" do
    map = DataImport.csv_map(@csv_path)
    #Logger.warn "csv_map.map:\n" <> inspect(map)
    assert !is_nil map
    assert length(map) == 7
  end

  test "upsert_nodes" do
    map = DataImport.csv_map(@csv_path)
    #Logger.warn "csv_map.map:\n" <> inspect(map)
    assert !is_nil map
    assert length(map) == 7
  end
end

# /Users/ernest/Developer/igwet/_build/test/lib/igwet/../../support/ingest-test.csv
