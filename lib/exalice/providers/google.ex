defmodule ExAlice.Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base

  @endpoint "https://maps.googleapis.com"

  def geocode(address) do
    request("/maps/api/geocode/json", address: address)
    |> parse_request
  end

  defp parse_request(response) do
    %HTTPoison.Response{:body => body} = response
    body = Poison.decode!(body)
    %{"results" => body} = body

    body
    |> Enum.map(&extract_payload/1)
  end

  defp extract_payload(body) do
    %{
      "geometry" => %{"location" => %{"lat" => lat, "lng" => lon}},
      "formatted_address" => full_address
    } = body

    %{lat: lat, lon: lon, full_address: full_address}
  end

  defp request(path, params) do
    params = Enum.into(params, %{})
    get!(@endpoint <> path, [], params: params)
  end
end
