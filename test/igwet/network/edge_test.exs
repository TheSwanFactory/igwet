defmodule Igwet.NetworkTest.Edge do
  use Igwet.DataCase

  alias Igwet.Network

  describe "edges" do
    alias Igwet.Network.Edge

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def edge_fixture(attrs \\ %{}) do
      {:ok, edge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_edge()

      edge
    end

    test "list_edges/0 returns all edges" do
      edge = edge_fixture()
      assert Network.list_edges() == [edge]
    end

    test "get_edge!/1 returns the edge with given id" do
      edge = edge_fixture()
      assert Network.get_edge!(edge.id) == edge
    end

    test "create_edge/1 with valid data creates a edge" do
      assert {:ok, %Edge{} = edge} = Network.create_edge(@valid_attrs)
    end

    test "create_edge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_edge(@invalid_attrs)
    end

    test "update_edge/2 with valid data updates the edge" do
      edge = edge_fixture()
      assert {:ok, edge} = Network.update_edge(edge, @update_attrs)
      assert %Edge{} = edge
    end

    test "update_edge/2 with invalid data returns error changeset" do
      edge = edge_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_edge(edge, @invalid_attrs)
      assert edge == Network.get_edge!(edge.id)
    end

    test "delete_edge/1 deletes the edge" do
      edge = edge_fixture()
      assert {:ok, %Edge{}} = Network.delete_edge(edge)
      assert_raise Ecto.NoResultsError, fn -> Network.get_edge!(edge.id) end
    end

    test "change_edge/1 returns a edge changeset" do
      edge = edge_fixture()
      assert %Ecto.Changeset{} = Network.change_edge(edge)
    end
  end
end
