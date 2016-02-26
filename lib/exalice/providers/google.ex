# took from
# https://github.com/knrz/geocoder/blob/master/lib/geocoder/providers/google_maps.ex

defmodule ExAlice.Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base
  use Towel

  @endpoint "https://maps.googleapis.com/"

  def geocode(address) when is_binary(address) do
    request("maps/api/geocode/json", address: address)
    |> fmap(&parse_geocode/1)
  end

  # add by kp
  def geocode(address) do
    request("maps/api/geocode/json", address: address)
    |> fmap(&parse_geocode/1)
  end

  defp parse_geocode(response) do
    coords = geocode_coords(response)
    location = geocode_location(response)
    Dict.put(coords, :location, location)
  end

  defp geocode_coords(%{"geometry" => %{"location" => coords}}) do
    %{"lat" => lat, "lng" => lon} = coords
    %{lat: lat, lon: lon}
  end


  @components ["locality", "administrative_area_level_1", "country", "route",
    "street_number", "postal_code"]
  @map %{
    "locality" => :city,
    "administrative_area_level_1" => :state,
    "country" => :country,
    "route" => :street,
    "street_number" => :housenumber,
    "postal_code" => :postcode
  }
  defp geocode_location(%{"address_components" => components}) do
    name = &Map.get(&1, "long_name")
    type = fn component ->
      component |> Map.get("types") |> Enum.find(&Enum.member?(@components, &1))
    end
    map = &({type.(&1), name.(&1)})
    reduce = fn {type, name}, location ->
      Map.put(location, Map.get(@map, type), name)
    end

    components
    |> Enum.filter_map(type, map)
    |> Enum.reduce(%{}, reduce)
  end

  defp request(path, params) do
    get(path, [], params: Enum.into(params, %{}))
    |> fmap(&Map.get(&1, :body))
    |> fmap(&Map.get(&1, "results"))
    |> fmap(&List.first/1)
  end

  defp process_url(url) do
    @endpoint <> url
  end

  defp process_response_body(body) do
    body |> Poison.decode!
  end
end
