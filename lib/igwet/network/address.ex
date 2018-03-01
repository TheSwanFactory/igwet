defmodule Igwet.Network.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Address
  alias Igwet.Network.Node

  schema "addresses" do
    field(:city, :string)
    field(:city_district, :string)
    field(:country, :string)
    field(:country_region, :string)
    field(:entrance, :string)
    field(:house_number, :string)
    field(:island, :string)
    field(:key, :string)
    field(:level, :string)
    field(:name, :string)
    field(:postcode, :string)
    field(:road_prefix, :string)
    field(:road_base, :string)
    field(:road_type, :string)
    field(:road_suffix, :string)
    field(:staircase, :string)
    field(:state, :string)
    field(:state_district, :string)
    field(:suburb, :string)
    field(:unit_type, :string)
    field(:unit_base, :string)
    field(:world_region, :string)

    belongs_to(:category, Node)
    has_many(:nodes, Node)

    timestamps()
  end

  @doc false
  def changeset(%Address{} = address, attrs) do
    address
    |> cast(attrs, [
      :name,
      :house_number,
      :road_prefix,
      :road_base,
      :road_type,
      :road_suffix,
      :unit_type,
      :unit_base,
      :city,
      :state,
      :postcode,
      :country
    ])
    |> validate_required([:name, :house_number, :road_base, :city, :state, :postcode, :country])
  end
end
