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
  end

  defp create_event(_) do
  end
end
