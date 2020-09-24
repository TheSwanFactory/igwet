defmodule Igwet.NetworkTest.DataImport do
  #require Logger
  use Igwet.DataCase
  alias Igwet.DataImport
  #alias Igwet.Network

  @test_csv "ingest-test.csv"
  #@test_dir Application.app_dir(:igwet, "../..")
  @csv_path Path.absname(@test_csv, "test/support")

  describe "read csv" do
    test "csv_map" do
      map = DataImport.csv_map(@csv_path)
      assert !is_nil map
    end
  end
end

# /Users/ernest/Developer/igwet/_build/test/lib/igwet/../../support/ingest-test.csv
