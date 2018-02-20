defmodule Igwet.Repo.Migrations.UniqueUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:authid])
  end
end
