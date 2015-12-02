defmodule ExAlice.Geocoder do
  use HTTPoison.Base

  def geocode(where) do
    {:ok, location} = ExAlice.Geocoder.Providers.GoogleMaps.geocode(where)

    location |> Poison.encode
  end
end
