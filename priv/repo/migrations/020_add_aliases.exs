defmodule Igwet.Repo.Migrations.AddAliases do
  use Ecto.Migration

  def change do
    alter table(:edges) do
      add :as, :string
    end
    alter table(:nodes) do
      add :initials, :string
    end
  end
end
