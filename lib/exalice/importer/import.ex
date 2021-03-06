defmodule ExAlice.Geocoder.Elastic.Import do
  alias ExAlice.Geocoder.Storage.Elastic.Indexer

  def import(file \\ false) do
    file = filename(file)

    index_name = ExAlice.Geocoder.config(:index)
    doc_type = ExAlice.Geocoder.config(:doc_type)

    bootstrap_index(index_name, doc_type)

    IO.puts("Importing...  #{file}")

    chunk_number = ExAlice.Geocoder.config(:chunks)

    chunked_stream =
      file
      |> file_stream()
      |> chunk(chunk_number)

    {time, _} = :timer.tc(fn -> spawn_workers_from_stream(chunked_stream) end, [])
    IO.puts("Import completed in #{time / 1000} ms")
  end

  defp filename(file) when is_binary(file), do: file
  defp filename(_file), do: ExAlice.Geocoder.config(:file)

  def spawn_workers_from_stream(stream) do
    stream
    |> Task.async_stream(fn chunk ->
      Indexer.index(chunk)
    end)
    |> Stream.run()
  end

  def file_stream(file) do
    File.stream!(file, read_ahead: 100_000)
  end

  def chunk(data, chunk_number) do
    Stream.chunk_every(data, chunk_number, chunk_number, [])
  end

  def bootstrap_index(index_name, doc_type) do
    settings = %{
      analysis: %{
        filter: %{edge_ngram: %{type: "edgeNGram", min_gram: 1, max_gram: 15}},
        analyzer: %{
          autocomplete_analyzer: %{
            filter: ["icu_normalizer", "icu_folding"],
            tokenizer: "icu_tokenizer"
          }
        }
      }
    }

    mappings = %{
      doc_type => %{
        "properties" => %{
          "coordinates" => %{"type" => "geo_point"},
          "full_address" => %{"type" => "text", "analyzer" => "autocomplete_analyzer"}
        }
      }
    }

    Elastic.HTTP.put("/#{index_name}", body: %{"settings" => settings, "mappings" => mappings})
  end
end
