defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  def import(_) do
    IO.puts "Importing..."

    File.stream!("data/germany-streets.json")
    |> Stream.chunk(5000)
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
