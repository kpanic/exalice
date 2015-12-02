defmodule ExAlice.Worker do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def handle_call(:geocode, _from, where) do
    {lat, lon} = ExAlice.Geocoder.geocode(where)
    {:reply, lat, lon}
  end
end
