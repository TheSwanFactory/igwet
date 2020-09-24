defmodule Igwet.DataImport do
  #require Logger
  #import Ecto.{Query}
  #alias Igwet.Network.Edge
  #alias Igwet.Network.Node
  #alias Igwet.Repo

  def map_strings_to_atoms(string_key_map) do
    # https://stackoverflow.com/questions/31990134/how-to-convert-map-keys-from-strings-to-atoms-in-elixir
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  def csv_map(path) do
    File.stream!(path)
    |> CSV.decode!(headers: true)
    |> Enum.each(&map_strings_to_atoms/1)
  end

end
