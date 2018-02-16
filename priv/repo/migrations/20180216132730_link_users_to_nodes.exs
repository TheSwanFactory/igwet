defmodule Igwet.Repo.Migrations.LinkUsersToNodes do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :node_id, references(:node)
    end
  end
end
