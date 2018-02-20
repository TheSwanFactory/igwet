defmodule Igwet.NetworkTest.Edge do
  use Igwet.DataCase
  alias Igwet.Network
  doctest Igwet.Network.Edge

  describe "edges" do
    alias Igwet.Network.Edge

    @invalid_attrs %{subject_id: nil, predicate_id: nil, object_id: nil}

    def make_node(name) do
      Network.create_node(%{name: name, key: "key.#{name}"})
    end

    def edge_attrs(name \\ "name") do
      {:ok, subject} = make_node("from.#{name}")
      {:ok, predicate} = make_node("by.#{name}")
      {:ok, object} = make_node("to.#{name}")
      %{subject_id: subject.id, predicate_id: predicate.id, object_id: object.id}
    end

    def edge_fixture(name \\ "fixture") do
      attrs = edge_attrs(name)
      {:ok, edge} = Network.create_edge(attrs)
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
      attrs = edge_attrs()
      assert {:ok, %Edge{} = edge} = Network.create_edge(attrs)
      subject = assoc(edge, :subject) |> Repo.one
      assert subject.id == attrs.subject_id
    end

    test "create_edge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_edge(@invalid_attrs)
    end

    test "update_edge/2 with valid data updates the edge" do
      edge = edge_fixture()
      update_attrs = edge_attrs("update")
      assert {:ok, edge2} = Network.update_edge(edge, update_attrs)
      assert %Edge{} = edge2

      subject = assoc(edge, :subject) |> Repo.one
      subject2 = assoc(edge2, :subject) |> Repo.one
      assert subject != subject2
      assert %{name: "from.update"} = subject2
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
