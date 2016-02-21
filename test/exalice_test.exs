defmodule ExAliceTest do
  use ExUnit.Case

  import Tirexs.Search
  require Tirexs.Query
  require Tirexs.ElasticSearch

  import ExAlice.Geocoder.Providers.Elastic.Indexer, only: [
    json_decode: 1, prepare_doc: 1, index_docs: 1]
  import ExAlice.Geocoder.Providers.Elastic.Importer, only: [
    file_stream: 1, chunk: 2]


  doctest ExAlice

  def setup_all do
    index_name = ExAlice.Geocoder.config(:index)
    settings = Tirexs.ElasticSearch.config()
    Tirexs.ElasticSearch.delete(index_name, settings)
    Tirexs.ElasticSearch.put(index_name, settings)
    Tirexs.Manage.refresh(Atom.to_string(index_name), settings)
    :ok
  end

  def indexing_prewarming(chunk_number \\ 10) do
    file = ExAlice.Geocoder.config(:file)
    file_stream(file)
    |> chunk(chunk_number)
    |> json_decode
  end

  test "expect that the chunks are split correctly" do
    # total chunks are 10 in data/test-data.json
    chunk_number = 2

    res = indexing_prewarming(chunk_number)

    assert Enum.count(res) == 5
  end


  test "expect that \"oversize\" chunks are split correctly" do
    # total chunks are 10 in data/test-data.json
    chunk_number = 100

    res = indexing_prewarming(chunk_number)

    assert Enum.count(res) == 1
  end

  @tag :pending
  test "expect that the chunk is indexed and split correctly" do
    indexing_prewarming
    |> prepare_doc
    |> index_docs

    settings = Tirexs.ElasticSearch.config()
    index_name = ExAlice.Geocoder.config(:index)

    Tirexs.Manage.refresh(to_string(index_name), settings)

    query = search [index: index_name] do
              query do
                string "*"
              end
            end

    result = Tirexs.Query.create_resource(query)
    result = Tirexs.Query.result(result, :hits)

    assert Enum.count(List.flatten(result)) == 10
  end
end
