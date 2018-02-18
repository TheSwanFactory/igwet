defmodule Igwet.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :city, :string
      add :city_district, :string
      add :country, :string
      add :country_region, :string
      add :entrance, :string
      add :house_number, :string
      add :island, :string
      add :key, :string
      add :level, :string
      add :name, :string
      add :postcode, :string
      add :road_base, :string
      add :road_prefix, :string
      add :road_suffix, :string
      add :road_type, :string
      add :staircase, :string
      add :state, :string
      add :state_district, :string
      add :suburb, :string
      add :unit_base, :string
      add :unit_type, :string
      add :world_region, :string

      add :category_id, references(:nodes, on_delete: :nothing)
      timestamps()
    end

    create index(:addresses, [:category_id])
  end
end
