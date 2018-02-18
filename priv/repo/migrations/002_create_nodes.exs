defmodule Igwet.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :about, :string
      add :date, :timestamp
      add :email, :string
      add :key, :string
      add :meta, :map
      add :name, :string
      add :phone, :string
      add :url, :string
      
      add :address_id, references(:addresses, on_delete: :nothing)

      timestamps()
    end

  end
end
