defmodule Igwet.Repo.Migrations.AddSizeToNodes do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :size, :integer, default: 1
    end
  end
end
