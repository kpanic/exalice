defmodule ExAliceAcceptanceTest do
  use ExUnit.Case

  @index_name ExAlice.Geocoder.config(:index)
  @doc_type ExAlice.Geocoder.config(:doc_type)
  @storage ExAlice.Geocoder.config(:provider)

  require Tirexs.Query
  import Tirexs.Resources.Indices
  import Tirexs.Search
  alias ExAlice.Geocoder.Providers.Elastic.Indexer

  import ExAlice.Geocoder.Providers.Elastic.Importer, only: [file_stream: 1, bootstrap_index: 2]

  doctest ExAlice

  setup do
    bootstrap_index(@index_name, @doc_type)
    Tirexs.Resources.bump._refresh(@index_name)
    on_exit fn ->
      Tirexs.HTTP.delete(@index_name)
      Tirexs.Resources.bump._refresh(@index_name)
    end
    :ok
  end

  test "expects that data is indexed with the openstreetmap geocoder" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    # Check if exists in the storage
    result = @storage.geocode("Via Gazzaniga")
    assert Enum.empty?(result)

    # Geocode and store in the storage
    result = ExAlice.Geocoder.geocode("Via Gazzaniga 26, Broni")
    Tirexs.Resources.bump._refresh(@index_name)

    assert not Enum.empty?(result)
  end


  test "expects that data is indexed with the google maps geocoder" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    # Geocode and store in the storage
    ExAlice.Geocoder.geocode("Via dei Recoaro 3, Broni")
    Tirexs.Resources.Indices._refresh(@index_name)

    result = ExAlice.Geocoder.geocode("Via dei Recoaro")

    assert not Enum.empty?(result)
  end

  test "expects empty list when geocoding an empty string" do

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    result = ExAlice.Geocoder.geocode("")
    assert Enum.empty?(result)
  end

  test "expects that a truncated address (or part of it), does not match an entry in the storage" do

    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Recoaro, Broni")
    Tirexs.Resources.bump._refresh(to_string(@index_name))

    result = @storage.geocode("Recoar")
    assert Enum.empty?(result)
  end

  # FIXME: OSM does not interpolate for every OSM address At some point we
  #        should strip the numbers in the case of openstreetmap when geocoding
  #        with the storage
  test "expects that an address with a number in OSM, does not matches an entry in the storage" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.OpenStreetMap)

    ExAlice.Geocoder.geocode("Via Emilia 3, Broni")
    Tirexs.Resources.bump._refresh(to_string(@index_name))

    result = @storage.geocode("Via Emilia 3")
    assert Enum.empty?(result)
  end

  test "expects that an address with a number in Google Maps, matches an entry in the storage" do
    Application.put_env(:exalice, :geocoder, ExAlice.Geocoder.Providers.GoogleMaps)

    ExAlice.Geocoder.geocode("Via Parini 3, Broni")
    Tirexs.Resources.bump._refresh(@index_name)

    result = @storage.geocode("Via Parini 3")

    assert not Enum.empty?(result)
  end

  test "expect that the chunk is indexed and split correctly" do
    file = ExAlice.Geocoder.config(:file)
    file_stream(file)
    |> Indexer.index
    Tirexs.Resources.bump._refresh(@index_name)

    query = search [index: @index_name] do
      query do
        match_all
      end
    end
    {:ok, 200, result} = Tirexs.Query.create_resource(query)
    %{hits: %{hits: result}} = result

    # Only 6 "right" docs where indexed, 4 were discarded
    assert Enum.count(result) == 6
  end
end
