defmodule Igwet.Repo.Migrations.CreateInstances do
  use Ecto.Migration

  def change do
    create table(:instances) do
      add :date, :date
      add :duration, :integer
      add :capacity, :integer
      add :registered, :integer
      add :node_id, references(:node, on_delete: :nothing)

      timestamps()
    end

    create index(:instances, [:node_id, :date])
  end
end
