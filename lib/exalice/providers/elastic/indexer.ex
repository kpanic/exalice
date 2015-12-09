defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do

  require UUID
  require Record
  Record.defrecord :erls_params, ExAlice.Geocoder.config(:erls_params)

  @index_name ExAlice.Geocoder.config(:index)

  def index(documents) do
    documents
    |> prepare_doc
    |> index_docs
  end

  defp prepare_doc(docs) when is_list(docs) do
    Enum.map(docs, fn doc -> [{@index_name, "location", UUID.uuid4(),
        Map.to_list(doc)}] end)
  end

  defp prepare_doc(doc) do
    [{@index_name, "location", UUID.uuid4(), Map.to_list(doc)}]
  end

  defp index_docs(docs) do
    params = erls_params()
    docs = List.flatten(docs)
    # TODO: Convert docs to a common format before indexing
    :erlastic_search.bulk_index_docs(params, docs)
  end
end
