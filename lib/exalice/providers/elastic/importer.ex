defmodule ExAlice.Geocoder.Providers.Elastic.Importer do

  import Tirexs.Mapping
  import Tirexs.Index.Settings
  alias Experimental.Flow

  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  def import(file \\ false) do
    file = case is_binary(file) do
             true ->
               file
             _ ->
               ExAlice.Geocoder.config(:file)
           end

    index_name = ExAlice.Geocoder.config(:index)
    doc_type = ExAlice.Geocoder.config(:doc_type)

    bootstrap_index(index_name, doc_type)

    IO.puts "Importing...  #{file}"

    chunk_number = ExAlice.Geocoder.config(:chunks)
    file
    |> file_stream()
    |> chunk(chunk_number)
    |> spawn_workers_from_stream()

  end

  def spawn_workers_from_stream(stream) do
    Flow.new(max_demand: 1)
    |> Flow.from_enumerable(stream)
    |> Flow.map(fn chunk ->
      Indexer.index(chunk)
    end)
    |> Flow.run
  end

  def file_stream(file) do
    File.stream!(file, read_ahead: 100_000)
  end

  def chunk(data, chunk_number) do
    Stream.chunk(data, chunk_number, chunk_number, [])
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
end
