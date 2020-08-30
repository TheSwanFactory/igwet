defmodule Igwet.Igwet.Network.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :capacity, :integer
    field :date, :date
    field :duration, :integer
    field :registered, :integer
    field :node_id, :id

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:date, :duration, :capacity, :registered])
    |> validate_required([:date, :duration, :capacity, :registered])
  end
end
