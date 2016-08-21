defmodule ExAlice.Geocoder do
  @behaviour Storage

  use HTTPoison.Base

  def geocode(_, _, "") do
    []
  end

  def geocode(storage \\ ExAlice.Geocoder.config(:provider),
              geocoder \\ ExAlice.Geocoder.config(:geocoder),
              where) do
    address = storage.geocode(where)
    case Enum.empty?(address) do
      true ->
        address = geocoder.geocode(where)
        {:ok, 200, something} = store(storage, address)
        address
      _ ->
        address
    end
  end

  def store(storage, address) do
    storage.index(address)
  end

  def config(key, app \\ :exalice, default \\ nil) do
    Application.get_env(app, key, default)
  end
end
