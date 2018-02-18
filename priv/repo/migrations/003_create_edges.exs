defmodule Igwet.Repo.Migrations.CreateEdges do
  use Ecto.Migration

  def change do
    create table(:edges) do
      add :subject_id, references(:nodes, on_delete: :nothing)
      add :predicate_id, references(:nodes, on_delete: :nothing)
      add :object_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:edges, [:subject_id])
    create index(:edges, [:predicate_id])
    create index(:edges, [:object_id])
  end
end
