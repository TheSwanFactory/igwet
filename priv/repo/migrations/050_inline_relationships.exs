defmodule Igwet.Repo.Migrations.InlineRelationships do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add(:parent_id, references(:nodes, on_delete: :delete_all, type: :uuid))
      add(:type, :string)
    end
    alter table(:edges) do
      add :relation, :string
    end
  end
end
