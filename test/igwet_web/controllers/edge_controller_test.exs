defmodule IgwetWeb.EdgeControllerTest do
  use IgwetWeb.ConnCase

  alias Igwet.Network

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:edge) do
    {:ok, edge} = Network.create_edge(@create_attrs)
    edge
  end

  describe "index" do
    test "lists all edges", %{conn: conn} do
      conn = get conn, edge_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Edges"
    end
  end

  describe "new edge" do
    test "renders form", %{conn: conn} do
      conn = get conn, edge_path(conn, :new)
      assert html_response(conn, 200) =~ "New Edge"
    end
  end

  describe "create edge" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, edge_path(conn, :create), edge: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == edge_path(conn, :show, id)

      conn = get conn, edge_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Edge"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, edge_path(conn, :create), edge: @invalid_attrs
      assert html_response(conn, 200) =~ "New Edge"
    end
  end

  describe "edit edge" do
    setup [:create_edge]

    test "renders form for editing chosen edge", %{conn: conn, edge: edge} do
      conn = get conn, edge_path(conn, :edit, edge)
      assert html_response(conn, 200) =~ "Edit Edge"
    end
  end

  describe "update edge" do
    setup [:create_edge]

    test "redirects when data is valid", %{conn: conn, edge: edge} do
      conn = put conn, edge_path(conn, :update, edge), edge: @update_attrs
      assert redirected_to(conn) == edge_path(conn, :show, edge)

      conn = get conn, edge_path(conn, :show, edge)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, edge: edge} do
      conn = put conn, edge_path(conn, :update, edge), edge: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Edge"
    end
  end

  describe "delete edge" do
    setup [:create_edge]

    test "deletes chosen edge", %{conn: conn, edge: edge} do
      conn = delete conn, edge_path(conn, :delete, edge)
      assert redirected_to(conn) == edge_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, edge_path(conn, :show, edge)
      end
    end
  end

  defp create_edge(_) do
    edge = fixture(:edge)
    {:ok, edge: edge}
  end
end
