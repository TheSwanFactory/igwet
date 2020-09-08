defmodule Igwet.Repo.Migrations.ModifyNodesAbout do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      modify :about, :text
    end
  end
end
