defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  import Tirexs.Mapping
  import Tirexs.Index.Settings

  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  def import(file \\ false) do
    unless is_binary(file) do
      file = ExAlice.Geocoder.config(:file)
    end

    index_name = ExAlice.Geocoder.config(:index)
    doc_type = ExAlice.Geocoder.config(:doc_type)

    bootstrap_index(index_name, doc_type)

    IO.puts "Importing...  #{file}"

    chunk_number = ExAlice.Geocoder.config(:chunks)

    stream = file
    |> file_stream
    |> chunk(chunk_number)

    ExAlice.StreamRunner.run(ExAlice.StreamRunner, stream, fn chunk ->
      Indexer.index(chunk)
    end)

    {time, _} = :timer.tc(ExAlice.StreamRunner, :await, [ExAlice.StreamRunner])
    IO.puts "Import completed in #{time / 1000} ms"
  end

  def bootstrap_index(index_name, doc_type) do
    index = [index: index_name, type: doc_type]

    settings do
      analysis do
        analyzer "autocomplete_analyzer",
          [
            filter: ["icu_normalizer", "icu_folding", "edge_ngram"],
            tokenizer: "icu_tokenizer"
          ]
        filter "edge_ngram", [type: "edgeNGram", min_gram: 1, max_gram: 15]
      end
    end

    mappings do
      indexes "coordinates", type: "geo_point"
      indexes "full_address", type: "string", analyzer: "autocomplete_analyzer"
    end

    Tirexs.Mapping.create_resource(index)
  end

  def file_stream(file) do
    File.stream!(file)
    |> Stream.map(&String.strip/1)
  end

  def chunk(data, chunk_number) do
    Stream.chunk(data, chunk_number, chunk_number, [])
  end
end
