defmodule ExAlice.Geocoder do
  @behaviour Storage

  use HTTPoison.Base

  def geocode(storage \\ ExAlice.Geocoder.config(:provider),
              geocoder \\ ExAlice.Geocoder.config(:geocoder),
              where) do
    address = storage.geocode(where)
    if Enum.empty?(address) do
      address = geocoder.geocode(where)
      if not Enum.empty?(address) do
        {:ok, 200, _} = store(storage, address)
      end
    end
    address
  end

  def store(storage, address) do
    storage.index(address)
  end

  def config(key, app \\ :exalice, default \\ nil) do
    Application.get_env(app, key, default)
  end
end
