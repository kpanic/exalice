defmodule ExAlice.Geocoder.Providers.Elastic do
  import Tirexs.Search

  require Tirexs.Query

  alias ExAlice.Geocoder.Providers.Elastic.Indexer


  def geocode(address) do
    index = ExAlice.Geocoder.config(:index)

    locations = search [index: index] do
      query do
        filtered do
          query do
          match "index.full_address", address,
          [operator: "and"]
          end
        end
      end
    end

    {:ok, 200, %{hits: hits}} = Tirexs.Query.create_resource(locations)

    Map.get(hits, :hits)
    |> Enum.map(fn item -> Map.get(item, :_source) end)
  end

  def index(data) when is_list(data) do
    Indexer.index(data)
  end
end
