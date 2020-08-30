defmodule Igwet.Network.Instance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "instances" do
    field :capacity, :integer
    field :date, :date
    field :duration, :integer
    field :registered, :integer
    field :node_id, :id

    timestamps()
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [:date, :duration, :capacity, :registered])
    |> validate_required([:date, :duration, :capacity])
  end
end
