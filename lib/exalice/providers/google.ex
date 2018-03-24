defmodule ExAlice.Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base

  @endpoint "https://maps.googleapis.com"

  def geocode(address) do
    request("/maps/api/geocode/json", address: address)
    |> parse_request
  end

  defp parse_request(%HTTPoison.Response{body: body}) do
    %{"results" => body} = Poison.decode!(body)

    body
    |> Enum.map(&extract_payload/1)
  end

  defp extract_payload(%{
         "geometry" => %{"location" => %{"lat" => lat, "lng" => lon}},
         "formatted_address" => full_address
       }) do
    %{lat: lat, lon: lon, full_address: full_address}
  end

  defp request(path, params) do
    params = Enum.into(params, %{})
    get!(@endpoint <> path, [], params: params)
  end
end
