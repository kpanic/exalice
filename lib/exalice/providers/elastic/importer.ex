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
        json_chunk = "[" <> Enum.join(chunk, ",") <> "]"

        json_chunk
        |> Poison.decode!
    end)
    |> Enum.map(&spawn(__MODULE__, :index, [&1]))
  end

  def index(chunks) do
    ExAlice.Geocoder.Providers.Elastic.Indexer.index(chunks)
  end
end
