defmodule Igwet.Repo.Migrations.AddParentToNodes do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add(:parent_id, references(:nodes, on_delete: :delete_all, type: :uuid))
      add(:type_id, references(:nodes, on_delete: :delete_all, type: :uuid))
    end
  end
end
