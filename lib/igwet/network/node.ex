defmodule Igwet.Network.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Admin.User
  alias Igwet.Network.Address
  alias Igwet.Network.Edge
  alias Igwet.Network.Node

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "nodes" do
    field(:about, :string)
    field(:date, :utc_datetime)
    field(:email, :string)
    field(:initials, :string)
    field(:key, :string)
    #field(:meta, :map)
    field(:name, :string)
    field(:phone, :string)
    field(:url, :string)

    belongs_to(:address, Address)
    has_many(:edges, Edge, foreign_key: :subject_id)
    has_one(:user, User)
    embeds_one :meta, Details, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [:about, :date, :email, :initials, :key, :name, :phone, :url])
    |> cast_embed(:meta)
    |> validate_required([:key, :name])
    |> unique_constraint(:key)
  end
end
