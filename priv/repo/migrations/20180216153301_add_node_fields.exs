defmodule Igwet.Repo.Migrations.AddNodeFields do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :url, :string
      add :date, :timestamp
      add :meta, :map
      #add :address_id, references(:addresses, on_delete: :nothing)
    end
  end
end
