defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  require UUID
  require Record
  Record.defrecord :erls_params, [host: "127.0.0.1", port: 9200, http_client_options: [],
    timeout: :infinity, ctimeout: :infinity]

  @index_name "exalice"

  def index(documents) do
    documents = prepare_bulk(documents)
    IO.inspect documents
    index_docs(documents)
  end

  defp index_docs(docs) do
    params = erls_params()
    IO.inspect params
    :erlastic_search.bulk_index_docs(params, docs)
  end

  defp prepare_bulk(response, result \\ []) do
    add_bulk_metadata(response, result)
  end

  defp add_bulk_metadata([head, tail], result) do
    add_bulk_metadata(tail, result ++ [{"exalice", "location", UUID.uuid4(),
       Map.to_list(head)}])
  end

  defp add_bulk_metadata([content], result) do
    result ++ [{"exalice", "location", UUID.uuid4(), Map.to_list(content)}]
  end

  defp add_bulk_metadata([], result) do
    [{"exalice", "location", UUID.uuid4(), Map.to_list(result)}]
  end

end
