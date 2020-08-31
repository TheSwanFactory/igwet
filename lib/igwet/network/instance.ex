defmodule Igwet.Network.Instance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Node

  schema "instances" do
    field :capacity, :integer
    field :starting, :utc_datetime
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
    |> cast(attrs, [:starting, :duration, :capacity, :registered, :recurrence])
    |> validate_required([:starting, :duration, :capacity])
    |> optimistic_lock(:lock_version)
  end
end
