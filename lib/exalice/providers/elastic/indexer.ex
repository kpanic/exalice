defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  require UUID
  require Record
  Record.defrecord :erls_params, [host: "127.0.0.1", port: 9200, http_client_options: [],
    timeout: :infinity, ctimeout: :infinity]

  @index_name "exalice"

  def index(documents) do
    documents
    |> prepare_doc
    |> index_docs
  end

  defp prepare_doc(docs) when is_list(docs) do
    Enum.map(docs, fn doc -> [{"exalice", "location", UUID.uuid4(),
        Map.to_list(doc)}] end)
  end

  defp prepare_doc(doc) do
    [{"exalice", "location", UUID.uuid4(), Map.to_list(doc)}]
  end

  defp index_docs(docs) do
    params = erls_params()
    docs = List.flatten(docs)
    # TODO: Convert docs to a common format before indexing
    :erlastic_search.bulk_index_docs(params, docs)
  end
end
