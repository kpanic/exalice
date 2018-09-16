defmodule ExAliceAcceptanceTest do
  use ExUnit.Case

  @index_name ExAlice.Geocoder.config(:index)
  @doc_type ExAlice.Geocoder.config(:doc_type)
  @storage ExAlice.Geocoder.config(:provider)

  import ExAlice.Geocoder.Elastic.Import,
    only: [file_stream: 1, bootstrap_index: 2, chunk: 2]

  setup do
    bootstrap_index(@index_name, @doc_type)
    Elastic.Index.refresh(@index_name)

    on_exit(fn ->
      Elastic.Index.delete(@index_name)
      Elastic.Index.refresh(@index_name)
    end)

    :ok
  end

  test "expects that data is indexed with the openstreetmap geocoder" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    # Check if exists in the storage
    result = @storage.geocode("Via Gazzaniga")
    assert Enum.empty?(result) == true

    # Geocode and store in the storage
    result = ExAlice.Geocoder.geocode("Via Gazzaniga 26, Broni")
    Elastic.Index.refresh(@index_name)

    assert not Enum.empty?(result) == true
  end

  @tag :skip
  test "expects that data is indexed with the google maps geocoder" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    # Geocode and store in the storage
    ExAlice.Geocoder.geocode("Via Recoaro, Broni")
    Elastic.Index.refresh(@index_name)

    result = ExAlice.Geocoder.geocode("Via dei Recoaro")

    assert not Enum.empty?(result) == true
  end

  test "expects empty list when geocoding an empty string" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    result = ExAlice.Geocoder.geocode("")
    assert Enum.empty?(result) == true
  end

  test "expects that a truncated address (or part of it), does not match an entry in the storage" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Recoaro, Broni")
    Elastic.Index.refresh(@index_name)

    result = @storage.geocode("Recoar")
    assert Enum.empty?(result) == true
  end

  # FIXME: OSM does not interpolate for every OSM address At some point we
  #        should strip the numbers in the case of openstreetmap when geocoding
  #        with the storage
  # Skip for now
  @tag :skip
  test "expects that an address with a number in OSM, does not matches an entry in the storage" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Emilia 3")
    Elastic.Index.refresh(@index_name)

    result = @storage.geocode("Via Emilia 3")
    assert Enum.empty?(result)
  end

  @tag :skip
  test "expects that an address with a number in Google Maps, matches an entry in the storage" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    ExAlice.Geocoder.geocode("Via Emilia 102, Broni")
    Elastic.Index.refresh(@index_name)

    result = @storage.geocode("Via Emilia 102")

    assert not Enum.empty?(result) == true
  end

  test "expect that the chunk is split correctly" do
    file = ExAlice.Geocoder.config(:file)

    result =
      file_stream(file)
      |> chunk(10)
      |> Enum.to_list()
      |> List.flatten()

    assert Enum.count(result) == 10
  end
end
