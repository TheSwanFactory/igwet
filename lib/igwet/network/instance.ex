defmodule Igwet.Network.Instance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Node

  schema "instances" do
    field :capacity, :integer
    field :duration, :integer
    field :lock_version, :integer, default: 1
    field :recurrence, :integer
    field :registered, :integer
    field :starting, :naive_datetime
    field :timezone, :string, default: "US/Pacific"
    belongs_to(:event, Node)

    timestamps()
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [:capacity, :duration, :recurrence, :registered, :starting, :timezone])
    |> validate_required([:duration, :timezone, :starting])
    |> optimistic_lock(:lock_version)
  end
end
