defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  def import(_) do
    IO.puts "Importing..."

    File.stream!("data/germany-streets.json")
    # |> Stream.map("\n", &(&1))
    # |> IO.inspect
    # |> Stream.each(fn chunk -> decode(chunk) end)
    # |> Stream.each(fn chunk -> collect(chunk) end)
    |> Stream.chunk(2)
    |> Stream.map(&poison_decode(&1))
    |> Stream.map(&(&1))
    |> Stream.map(&index(&1))
    |> Stream.run

  end

  defp poison_decode(chunk) do
    {:ok, content} = Poison.decode(String.split(List.first(chunk), "\n"))
    content
  end

  defp index(chunks) do
    # content = String.split(big_chunk, "\n", trim: true)

    # chunks = decode_chunks(content)
    ExAlice.Geocoder.Providers.Elastic.Indexer.index(chunks)
  end

  defp decode_chunks(content, chunks \\ []) do
    decode(content, chunks)
  end

  defp decode([head|tail], chunks) do
    {:ok, content} = Poison.decode(head)
    decode(tail, chunks ++ [content])
  end

  defp decode([], chunks) do
    chunks
  end
end
