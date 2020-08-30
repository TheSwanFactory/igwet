defmodule Igwet.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :date, :date
      add :duration, :integer
      add :capacity, :integer
      add :registered, :integer
      add :node_id, references(:node, on_delete: :nothing)

      timestamps()
    end

    create index(:events, [:node_id])
  end
end
