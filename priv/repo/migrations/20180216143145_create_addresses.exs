defmodule Igwet.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :name, :string
      add :house_number, :string
      add :road, :string
      add :unit, :string
      add :city, :string
      add :state, :string
      add :postcode, :string
      add :country, :string
      add :level, :string
      add :staircase, :string
      add :entrance, :string
      add :suburb, :string
      add :city_district, :string
      add :island, :string
      add :state_district, :string
      add :country_region, :string
      add :world_region, :string
      add :category_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:addresses, [:category_id])
  end
end
