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
          match "full_address", address,
          [operator: "and"]
          end
        end
      end
    end

    result = Tirexs.Query.create_resource(locations)


    Tirexs.Query.result(result, :hits)
    |> Enum.map(fn item -> Map.get(item, :_source) end)
  end

  def index(data) when is_list(data) do
    Indexer.index(data)
  end
end
