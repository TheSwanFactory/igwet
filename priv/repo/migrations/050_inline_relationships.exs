defmodule Igwet.Repo.Migrations.InlineRelationships do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add(:type, :string)
    end
    alter table(:edges) do
      add :relation, :string
    end
  end
end
