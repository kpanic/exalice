defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  import Tirexs.Bulk
  require Tirexs.ElasticSearch

  @settings Tirexs.ElasticSearch.config()

  require UUID

  @index_name ExAlice.Geocoder.config(:index)

  def index(documents) do
    documents
    |> prepare_doc
    |> index_docs
  end

  defp prepare_doc(docs) when is_list(docs) do
    Stream.map(docs, fn doc ->
      doc = filter_doc(doc)
      metadata = [{:type, "location"}, {:_id, UUID.uuid4()}]
      merged_doc = Keyword.merge(doc, metadata)
      [{:index, merged_doc}]
    end)
  end

  defp prepare_doc(doc) do
      doc = filter_doc(doc)
      IO.inspect doc
      metadata = [{:type, "location"}, {:_id, UUID.uuid4()}]
      merged_doc = Keyword.merge(doc, metadata)
      [{:index, merged_doc}]
  end

  defp filter_doc(%{"lat" => lat, "lon" => lon,
    "tags" =>
      %{"addr:city" => city, "addr:country" => country,
        "addr:housenumber" => housenumber, "addr:postcode" => postcode,
        "addr:street" => street}
    }) do

    coordinates = [{:lat, lat}, {:lon, lon}]
    location = [{:location, [{:city, city}, {:state, country},
        {:street, street}, {:housenumber, housenumber},
        {:postcode, postcode}]}]
    Keyword.merge(coordinates, location)
  end

  defp filter_doc(%{lat: lat, lon: lon,
     location: %{city: city, country: country,
       housenumber: housenumber, state: state,
       postcode: postcode, street: street},
     }) do

    coordinates = [{:lat, lat}, {:lon, lon}]
    location = [{:location, [{:city, city}, {:country, country},
          {:street, street}, {:housenumber, housenumber},
          {:postcode, postcode}, {:state, state}]}]
    Keyword.merge(coordinates, location)
  end

  defp filter_doc(_) do
    []
  end

  defp index_docs(docs) do
    docs
    # Discard not "pure" docs :)
    |> Enum.filter(fn(x) -> Enum.count(x) != 2 end)
    |> bulk_index
  end

  defp bulk_index(docs) do
    Tirexs.Bulk.store [index: @index_name, refresh: false], @settings, do: docs
  end
end
