defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  def import(file \\ false) do
    unless is_binary(file) do
      file = ExAlice.Geocoder.config(:file)
    end

    IO.puts "Importing...  #{file}"

    chunk_number = ExAlice.Geocoder.config(:chunks)

    read_file(file)
    |> chunk(chunk_number)
    |> json_decode
    # TODO: Figure out how to Task.async nicely, without OOM killers
    |> index
  end

  def read_file(file) do
    File.stream!(file)
    |> Enum.map(fn content -> String.split(content, "\n", trim: true) end)
  end

  def chunk(data, chunk_number) do
    Stream.chunk(data, chunk_number, chunk_number, [])
  end

  def json_decode(chunks) do
    Enum.map(chunks, fn chunk ->
        chunk = String.strip(Enum.join(chunk, ","), ?,)
        Poison.decode! "[" <> chunk <> "]"
    end)
  end

  def index(chunks) do
    Indexer.index chunks
  end
end
