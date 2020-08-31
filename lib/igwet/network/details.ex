
defmodule Details do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :capacity, :integer
    field :duration, :integer
    field :recurrence, :integer
    field :starting, :naive_datetime
    field :timezone, :string
  end

  @doc false
  def changeset(details, attrs) do
    details
    |> cast(attrs, [:capacity, :duration, :recurrence, :starting, :timezone])
    |> validate_required([:duration, :starting, :timezone])
  end
end
