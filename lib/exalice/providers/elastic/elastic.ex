defmodule ExAlice.Geocoder.Providers.Elastic do
  @es_index ExAlice.Geocoder.config(:index)
  @es_type ExAlice.Geocoder.config(:doc_type)

  use Elastic.Document.API

  alias __MODULE__, as: ES

  alias ExAlice.Geocoder.Providers.Elastic.Indexer


  def geocode(address) do
    locations =
      %{
        query: %{
          filtered: %{
            query: %{match: %{"full_address": %{query: address, operator: "and"}}}
          }
        }
      }


    {:ok, 200, %{"hits" => %{"hits" => hits}}} = ES.raw_search(locations)

    hits
    |> Enum.map(fn item -> Map.get(item, "_source") end)
  end

  def index(data) when is_list(data) do
    Indexer.index(data)
  end
end
