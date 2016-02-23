defmodule Storage do

  @callback geocode(storage :: atom, geocoder :: atom, address :: String.t) :: Map.t

  @callback store(storage :: atom, data :: list) :: Tuple.t

end
