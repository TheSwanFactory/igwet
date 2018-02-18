defmodule Igwet.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :authid, :string
      add :avatar, :string
      add :email, :string
      add :email_verified, :boolean
      add :family_name, :string
      add :given_name, :string
      add :last_login, :naive_datetime
      add :name, :string
      add :nickname, :string
      
      add :node_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

  end
end
