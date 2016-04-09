defmodule ExAliceAcceptanceTest do
  use ExUnit.Case

  require Tirexs.Query
  require Tirexs.ElasticSearch

  @index_name ExAlice.Geocoder.config(:index)
  @settings Tirexs.ElasticSearch.config()
  @storage ExAlice.Geocoder.config(:provider)

  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  import ExAlice.Geocoder.Providers.Elastic.Importer, only: [file_stream: 1]
  import ExAlice.Geocoder.Providers.Elastic.Indexer, only: [json_decode: 1]

  doctest ExAlice

  def setup do
    Tirexs.ElasticSearch.delete(@index_name, @settings)
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    Tirexs.ElasticSearch.post(@index_name, @settings)
    Tirexs.Manage.refresh(to_string(@index_name), @settings)
    :ok
  end

  def indexing_prewarming do
    file = ExAlice.Geocoder.config(:file)
    file_stream(file)
    |> Enum.take(10)
    |> json_decode
    |> Indexer.index

    Tirexs.Manage.refresh(to_string(@index_name), @settings)
  end

  test "expects that data is indexed with the openstreetmap geocoder" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    # Geocode and store in the storage
    ExAlice.Geocoder.geocode("Via Gazzaniga 26, Broni")
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    # Check if exists in the storage
    result = @storage.geocode("Via Gazzaniga")

    assert not Enum.empty?(result)

    response_stored = ExAlice.Geocoder.geocode("Via Gazzaniga 26, Broni")

    assert not Enum.empty?(response_stored)
  end


  test "expects that data is indexed with the google maps geocoder" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    # Geocode and store in the storage
    ExAlice.Geocoder.geocode("Via Recoaro 3, Broni")
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    result = @storage.geocode("Via Recoaro 3, Broni")

    assert not Enum.empty?(result)

    response_stored = ExAlice.Geocoder.geocode("Via Recoaro 3, Broni")

    assert not Enum.empty?(response_stored)
  end

  test "expects empty list when geocoding an empty string" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    result = ExAlice.Geocoder.geocode("")
    assert Enum.empty?(result)
  end

  test "expects that a truncated address (or part of it), does not match an entry in the storage" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Recoaro, Broni")
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    result = @storage.geocode("Recoar")
    assert Enum.empty?(result)
  end

  # FIXME: OSM does not interpolate for every OSM address At some point we
  #        should strip the numbers in the case of openstreetmap when geocoding
  #        with the storage
  test "expects that an address with a number in OSM, does not matches an entry in the storage" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Emilia 3, Broni")
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    result = @storage.geocode("Via Emilia 3")
    assert Enum.empty?(result)
  end

  test "expects that an address with a number in Google Maps, matches an entry in the storage" do
    indexing_prewarming()

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    ExAlice.Geocoder.geocode("Via Parini 3, Broni")
    Tirexs.Manage.refresh(to_string(@index_name), @settings)

    result = @storage.geocode("Via Parini, 3")

    assert not Enum.empty?(result)
  end
end
