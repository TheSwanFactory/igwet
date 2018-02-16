defmodule Igwet.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string
      add :email_verified, :boolean
      add :family_name, :string
      add :given_name, :string
      add :nickname, :string
    end
  end
end
