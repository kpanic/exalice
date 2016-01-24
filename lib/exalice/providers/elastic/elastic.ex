defmodule ExAlice.Geocoder.Providers.Elastic do
  import Tirexs.Search

  require Tirexs.Query

  @index ExAlice.Geocoder.config(:index)

  def geocode(address) do
    locations = search [index: @index] do
      query do
        filtered do
          query do
          match "location.full_address", address,
          [operator: "and"]
          end
        end
      end
    end
    IO.puts JSX.encode! locations

    result = Tirexs.Query.create_resource(locations)


    Tirexs.Query.result(result, :hits)
    |> Enum.map(fn item -> Map.get(item, :_source) end)
  end
end
