defmodule Igwet.Repo.Migrations.CreateInstances do
  use Ecto.Migration

  def change do
    create table(:instances) do
      add :date, :date
      add :duration, :integer
      add :capacity, :integer
      add :registered, :integer
      add :event_id, references(:nodes, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:instances, [:event_id, :date])
  end
end
