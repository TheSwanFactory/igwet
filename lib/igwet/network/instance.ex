defmodule Igwet.Network.Instance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Node

  schema "instances" do
    field :capacity, :integer
    field :date, :date
    field :duration, :integer
    field :lock_version, :integer, default: 1
    field :recurrence, :integer
    field :registered, :integer
    belongs_to(:event, Node)

    timestamps()
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [:date, :duration, :capacity, :registered])
    |> validate_required([:date, :duration, :capacity, :registered])
    |> optimistic_lock(:lock_version)
  end
end
