defmodule Igwet.Repo.Migrations.UniqueNodes do
  use Ecto.Migration

  def change do
    create unique_index(:nodes, [:key])
  end
end
