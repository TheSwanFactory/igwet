defmodule Igwet.Network.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Address


  schema "addresses" do
    field :city, :string
    field :city_district, :string
    field :country, :string
    field :country_region, :string
    field :entrance, :string
    field :house_number, :string
    field :island, :string
    field :level, :string
    field :name, :string
    field :postcode, :string
    field :road, :string
    field :staircase, :string
    field :state, :string
    field :state_district, :string
    field :suburb, :string
    field :unit, :string
    field :world_region, :string
    field :category_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Address{} = address, attrs) do
    address
    |> cast(attrs, [:name, :house_number, :road, :unit, :city, :state, :postcode, :country, :level, :staircase, :entrance, :suburb, :city_district, :island, :state_district, :country_region, :world_region])
    |> validate_required([:name, :house_number, :road, :unit, :city, :state, :postcode, :country, :level, :staircase, :entrance, :suburb, :city_district, :island, :state_district, :country_region, :world_region])
  end
end
