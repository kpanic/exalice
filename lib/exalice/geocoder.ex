defmodule ExAlice.Geocoder do
  use HTTPoison.Base
  alias ExAlice.Geocoder.Providers.Elastic, as: Elastic
  alias ExAlice.Geocoder.Providers.GoogleMaps, as: GoogleMaps

  def geocode(where) do
    location = Elastic.geocode(where)
    if location == [] do
      {:ok, location} = GoogleMaps.geocode(where)
      {:ok, 200, _} = Elastic.Indexer.index([location])

    end
    location
  end

  def config(key, app \\ :exalice, default \\ nil) do
    Application.get_env(app, key, default)
  end
end
