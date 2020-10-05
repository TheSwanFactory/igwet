defmodule IgwetWeb.GroupControllerTest do
  use IgwetWeb.ConnCase
  alias Igwet.Network
  require Logger

  @group_attrs %{
    about: "about group",
    email: "some group email",
    key: "some group group key",
    name: "test group",
    phone: "some group phone",
    type: "group",
  }
  @update_attrs %{
    name: "some updated group",
    key: "some updated group key",
    date: ~N[2000-12-31 23:59:00],
    timezone: "US/Eastern",
  }
  @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil, meta: %{}}
  @test_path "test/support"
  @test_csv "ingest-test.csv"

  describe "index" do
    test "lists all groups", %{conn: conn} do
      conn = get(conn, group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Groups"
    end
  end

  describe "new group" do
    test "renders form", %{conn: conn} do
      {:ok, group} = Network.create_node(@group_attrs)
      conn = get(conn, group_path(conn, :new, id: group.id))
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "create group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, group_path(conn, :create), node: @group_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_path(conn, :show, id)

      conn = get(conn, group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Group"
    end

    test "for group", %{conn: conn} do
      post(conn, group_path(conn, :create), node: @group_attrs)

      my_group = Network.get_predicate(@group_attrs.name)
      assert my_group.type == "group"
    end

    test "redirects back to edit data is invalid", %{conn: conn} do
      conn = post(conn, group_path(conn, :create), node: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "edit group" do
    setup [:create_group]

    test "renders form for editing chosen group", %{conn: conn, group: group} do
      conn = get(conn, group_path(conn, :edit, group))
      result = html_response(conn, 200)
      assert result =~ "Edit Group"
      assert result =~ "multipart"
      assert result =~ "file"
      assert result =~ "node[import]"
    end
  end

  describe "update group" do
    setup [:create_group]

    test "redirects when data is valid", %{conn: conn, group: group} do
      upload = %Plug.Upload{content_type: "group/csv", filename: @test_csv, path: @test_path}
      params = Map.put(@update_attrs, "import", upload)
      conn = put(conn, group_path(conn, :update, group), node: params)
      assert redirected_to(conn) == group_path(conn, :show, group)

      conn = get(conn, group_path(conn, :show, group))
      assert html_response(conn, 200) =~ "some updated group"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put(conn, group_path(conn, :update, group), node: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete(conn, group_path(conn, :delete, group))
      assert redirected_to(conn) == group_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, group_path(conn, :show, group))
      end
    end
  end

  defp create_group(_) do
    {:ok, group} = Network.create_node(@group_attrs)
    %{group: group}
  end
end
