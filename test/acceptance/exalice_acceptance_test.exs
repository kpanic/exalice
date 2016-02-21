defmodule ExAliceAcceptanceTest do
  use ExUnit.Case

  import Tirexs.Search
  require Tirexs.Query
  require Tirexs.ElasticSearch

  @index_name ExAlice.Geocoder.config(:index)
  @settings Tirexs.ElasticSearch.config()

  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  import ExAlice.Geocoder.Providers.Elastic.Importer, only: [file_stream: 1]
  import ExAlice.Geocoder.Providers.Elastic.Indexer, only: [json_decode: 1]

  doctest ExAlice

  def setup_all do
    Tirexs.ElasticSearch.delete(@index_name, @settings)
    Tirexs.ElasticSearch.put(@index_name, @settings)
    Tirexs.Manage.refresh(Atom.to_string(@index_name), @settings)
    :ok
  end

  def indexing_prewarming do
    file = ExAlice.Geocoder.config(:file)
    file_stream(file)
    |> Enum.take(10)
    |> json_decode
  end

  test "expects that data is indexed" do
    indexing_prewarming
    |> Indexer.index

    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    # Geocode and store in the storage
    ExAlice.Geocoder.geocode("Via Recoaro 3, Broni")

    # Check if exists in the storage
    query = search [index: @index_name] do
      query do
        string "Via Recoaro"
      end
    end

    result = Tirexs.Query.create_resource(query)
    result = Tirexs.Query.result(result, :hits)

    response_stored = ExAlice.Geocoder.geocode("Via Recoaro 3, Broni")

    assert not Enum.empty?(response_stored)
  end
end
