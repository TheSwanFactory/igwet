defmodule Igwet.NetworkTest.Address do
  use Igwet.DataCase

  alias Igwet.Network

  describe "addresses" do
    alias Igwet.Network.Address

    @valid_attrs %{city: "some city", country: "some country", house_number: "some house_number", name: "some name", postcode: "some postcode", road_base: "some road", state: "some state",  unit_base: "some unit_base", unit_type: "some unit_type"}
    @update_attrs %{city: "next city", country: "next country", house_number: "next house_number", name: "next name", postcode: "next postcode", road_base: "next road", state: "next state",  unit_base: "next unit_base", unit_type: "next unit_type"}
    @invalid_attrs %{city: nil, name: nil, postcode: nil, state: nil, state_district: nil, suburb: nil, world_region: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Network.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Network.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Network.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Network.create_address(@valid_attrs)
      assert address.city == "some city"
      assert address.country == "some country"
      assert address.house_number == "some house_number"
      assert address.name == "some name"
      assert address.postcode == "some postcode"
      assert address.road_base == "some road"
      assert address.state == "some state"
      assert address.unit_base == "some unit_base"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, address} = Network.update_address(address, @update_attrs)
      assert %Address{} = address
      assert address.city == "next city"
      assert address.country == "next country"
      assert address.house_number == "next house_number"
      assert address.name == "next name"
      assert address.postcode == "next postcode"
      assert address.road_base == "next road"
      assert address.state == "next state"
      assert address.unit_base == "next unit_base"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_address(address, @invalid_attrs)
      assert address == Network.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Network.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Network.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Network.change_address(address)
    end
  end
end
