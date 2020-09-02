defmodule Igwet.Repo.Migrations.AddTzToNodes do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :timezone, :string, default: "US/Pacific"
      modify :date, :naive_datetime
    end
  end
end
