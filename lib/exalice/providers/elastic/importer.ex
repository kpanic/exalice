defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  def import(file \\ false) do
    unless is_binary(file) do
      file = ExAlice.Geocoder.config(:file)
    end

    IO.puts "Importing..."

    chunk_number = ExAlice.Geocoder.config(:chunks)

    File.stream!(file)
    |> Stream.chunk(chunk_number, chunk_number, [])
    |> Stream.map(fn chunk ->
        chunk
        |> Stream.map(&Poison.decode!(&1))
    end)
    |> Enum.map(&Task.async(fn -> index(&1) end))
    # |> Enum.map(&Task.await/1)
        # chunk
        # |> Enum.map(fn(doc) -> (fn -> doc end )end)
        # |> Enum.map(&Task.async(fn -> index(&1) end))
        # |> Enum.map(&Task.await/1)
    # end)
  end

  defp index(chunks) do
    ExAlice.Geocoder.Providers.Elastic.Indexer.index(chunks)
  end
end
