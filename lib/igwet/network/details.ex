
defmodule Details do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :capacity, :integer
    field :current, :integer
    field :duration, :integer
    field :recurrence, :integer
    field :starting, :naive_datetime
    field :timezone, :string
    field :parent_id, :binary_id
  end

  @doc false
  def changeset(details, attrs) do
    details
    |> cast(attrs, [:capacity, :current, :duration, :recurrence, :starting, :timezone, :parent_id])
#    |> validate_required([:duration, :starting, :timezone])
  end
end
