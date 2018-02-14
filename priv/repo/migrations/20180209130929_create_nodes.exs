defmodule Igwet.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :name, :string
      add :about, :string
      add :email, :string
      add :phone, :string
      add :key, :string

      timestamps()
    end

  end
end
