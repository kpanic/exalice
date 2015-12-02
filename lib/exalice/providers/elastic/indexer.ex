defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do

  @index_name "exalice"

  def index(document) do
    {:ok, document} = Poison.encode(document)
    :erlastic_search.index_doc("exalice", "location", document)
  end
end
