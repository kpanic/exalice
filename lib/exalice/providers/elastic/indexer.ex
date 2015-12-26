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

  defp prepare_doc(docs) do
    docs = List.flatten docs
    Stream.map(docs, fn doc ->
      filter_doc(doc)
    end)
  end

  defp filter_doc(doc) do
    case doc do
      # openstreetmap format
      %{"lat" => lat, "lon" => lon,
        "tags" =>
        %{"addr:city" => city, "addr:country" => country,
          "addr:housenumber" => housenumber, "addr:postcode" => postcode,
          "addr:street" => street}
      } ->

        coordinates = [lat: lat, lon: lon]
        location = [location: [city: city,
            street: street, housenumber: housenumber,
            postcode: postcode, state: country]]
        metadata = [type: "location", _id: UUID.uuid4()]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      # geocoder format
      %{lat: lat, lon: lon,
        location: %{city: city, country: country,
          housenumber: housenumber, state: state,
          postcode: postcode, street: street}} ->

        coordinates = [lat: lat, lon: lon]
        location = [location: [city: city,
            street: street, housenumber: housenumber,
            postcode: postcode, state: country]]
        metadata = [type: "location", _id: UUID.uuid4()]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      _ ->
        metadata = [type: "location", _id: UUID.uuid4()]
        [index: metadata]
    end
  end

  defp index_docs(docs) do
    docs
    # Discard not "pure" docs :)
    |> discard_unparsable_docs
    |> bulk_index
  end

  defp discard_unparsable_docs(docs) do
    Enum.reject(docs, fn doc -> 
     values = Keyword.get_values(doc, :index)
     Enum.count(values) == 2
    end)
  end

  defp bulk_index(docs) do
    Tirexs.Bulk.store [index: @index_name, refresh: false], @settings, do: docs
  end
end
