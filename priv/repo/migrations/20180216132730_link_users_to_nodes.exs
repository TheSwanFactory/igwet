defmodule Igwet.Repo.Migrations.LinkUsersToNodes do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :node_id, references(:nodes, on_delete: :nothing)
    end
  end
end
