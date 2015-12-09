defmodule ExAlice.Geocoder do
  use HTTPoison.Base

  def geocode(where) do
    location = ExAlice.Geocoder.Providers.Elastic.geocode(where)
    if location == [] do
      {:ok, location} = ExAlice.Geocoder.Providers.GoogleMaps.geocode(where)
      {:ok, _} = ExAlice.Geocoder.Providers.Elastic.Indexer.index(location)
      location = [location]
    end
    location
  end

  def config(key, app \\ :exalice, default \\ nil) do
    Application.get_env(app, key, default)
  end
end
