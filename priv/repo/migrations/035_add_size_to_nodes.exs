defmodule Igwet.Repo.Migrations.AddTzToNodes do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :size, :integer, default: 1
    end
  end
end
