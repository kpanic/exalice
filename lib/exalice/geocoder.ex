defmodule ExAlice.Geocoder do
  @behaviour Storage

  def geocode(""), do: []
  def geocode(
        where,
        storage \\ ExAlice.Geocoder.config(:provider),
        geocoder \\ ExAlice.Geocoder.config(:geocoder)
      ) do
    address = storage.geocode(where)

    with true <- Enum.empty?(address),
         address = geocoder.geocode(where),
         true <- not Enum.empty?(address),
         {:ok, 200, _} <- store(storage, address)
    do
          address
    else
      _ -> address
    end
  end

  def store(storage, address) do
    storage.index(address)
  end

  def config(key, app \\ :exalice, default \\ nil) do
    Application.get_env(app, key, default)
  end
end
