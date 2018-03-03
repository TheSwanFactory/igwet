defmodule Igwet.Repo.Migrations.CategorizeAddresses do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add(:category_id, references(:nodes, on_delete: :nothing, type: :uuid))
    end

    create(index(:addresses, [:category_id]))
  end
end
