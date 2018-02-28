defmodule IgwetWeb.AddressControllerTest do
  use IgwetWeb.ConnCase

  alias Igwet.Network

  @create_attrs %{
    city: "some city",
    city_district: "some city_district",
    country: "some country",
    country_region: "some country_region",
    entrance: "some entrance",
    house_number: "some house_number",
    island: "some island",
    level: "some level",
    name: "some name",
    postcode: "some postcode",
    road_base: "some road_base",
    staircase: "some staircase",
    state: "some state",
    state_district: "some state_district",
    suburb: "some suburb",
    unit_base: "some unit_base",
    world_region: "some world_region"
  }
  @update_attrs %{
    city: "some updated city",
    city_district: "some updated city_district",
    country: "some updated country",
    country_region: "some updated country_region",
    entrance: "some updated entrance",
    house_number: "some updated house_number",
    island: "some updated island",
    level: "some updated level",
    name: "some updated name",
    postcode: "some updated postcode",
    road_base: "some updated road_base",
    staircase: "some updated staircase",
    state: "some updated state",
    state_district: "some updated state_district",
    suburb: "some updated suburb",
    unit_base: "some updated unit_base",
    world_region: "some updated world_region"
  }
  @invalid_attrs %{
    city: nil,
    city_district: nil,
    country: nil,
    country_region: nil,
    entrance: nil,
    house_number: nil,
    island: nil,
    level: nil,
    name: nil,
    postcode: nil,
    road_base: nil,
    staircase: nil,
    state: nil,
    state_district: nil,
    suburb: nil,
    unit_base: nil,
    world_region: nil
  }

  def fixture(:address) do
    {:ok, address} = Network.create_address(@create_attrs)
    address
  end

  describe "index" do
    test "lists all addresses", %{conn: conn} do
      conn = get(conn, address_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Addresses"
    end
  end

  describe "new address" do
    test "renders form", %{conn: conn} do
      conn = get(conn, address_path(conn, :new))
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  describe "create address" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, address_path(conn, :create), address: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == address_path(conn, :show, id)

      conn = get(conn, address_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Address"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, address_path(conn, :create), address: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  describe "edit address" do
    setup [:create_address]

    test "renders form for editing chosen address", %{conn: conn, address: address} do
      conn = get(conn, address_path(conn, :edit, address))
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  describe "update address" do
    setup [:create_address]

    test "redirects when data is valid", %{conn: conn, address: address} do
      conn = put(conn, address_path(conn, :update, address), address: @update_attrs)
      assert redirected_to(conn) == address_path(conn, :show, address)

      conn = get(conn, address_path(conn, :show, address))
      assert html_response(conn, 200) =~ "some updated city"
    end

    test "renders errors when data is invalid", %{conn: conn, address: address} do
      conn = put(conn, address_path(conn, :update, address), address: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  describe "delete address" do
    setup [:create_address]

    test "deletes chosen address", %{conn: conn, address: address} do
      conn = delete(conn, address_path(conn, :delete, address))
      assert redirected_to(conn) == address_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, address_path(conn, :show, address))
      end)
    end
  end

  defp create_address(_) do
    address = fixture(:address)
    {:ok, address: address}
  end
end
