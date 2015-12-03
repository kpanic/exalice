defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  require UUID
  require Record
  Record.defrecord :erls_params, [host: "127.0.0.1", port: 9200, http_client_options: [],
    timeout: :infinity, ctimeout: :infinity]

  @index_name "exalice"

  def index(documents) do
    documents
    |> Enum.map(&prepare_doc(&1))
    |> index_docs
  end

  defp prepare_doc(doc) do
    [{"exalice", "location", UUID.uuid4(), Map.to_list(doc)}]
  end

  defp index_docs(docs) do
    params = erls_params()
    docs = List.flatten(docs)
    :erlastic_search.bulk_index_docs(params, docs)
  end
end
