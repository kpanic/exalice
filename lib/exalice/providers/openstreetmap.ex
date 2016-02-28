defmodule ExAlice.Geocoder.Providers.OpenStreetMap do
  use HTTPoison.Base

  @endpoint "http://nominatim.openstreetmap.org"
  @format "json"

  def geocode(address) do
    request("/search", [q: address, format: @format])
    |> parse_request
  end

  defp parse_request(response) do
	  %HTTPoison.Response{body: body} = response
    Poison.decode!(body)
    |> Enum.map(&extract_payload/1)
  end

  defp extract_payload(body) do
	  %{"lat" => lat, "lon" => lon, "display_name" => full_address} = body
    %{lat: lat, lon: lon, full_address: full_address}
  end

  defp request(path, params) do
    params = Enum.into(params, %{})
	  get!(@endpoint <> path, [], params: params)
  end
end
