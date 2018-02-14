defmodule Igwet.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :authid, :string
      add :name, :string
      add :avatar, :string
      add :last_login, :naive_datetime
    end

  end
end
