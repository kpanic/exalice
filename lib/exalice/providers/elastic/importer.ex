defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  def import(file \\ false) do
    unless is_binary(file) do
      file = "data/germany-streets.json"
    end

    IO.puts "Importing..."

    File.stream!(file)
    |> Stream.chunk(5000, 5000, [])
    |> Stream.map(fn chunk ->
        chunk
        |> Stream.map(&Poison.decode!(&1))
    end)
    |> Enum.map(fn chunk ->
        chunk
        |> Enum.map(&(&1))
        |> index
    end)
  end

  defp index(chunks) do
    ExAlice.Geocoder.Providers.Elastic.Indexer.index(chunks)
  end
end
