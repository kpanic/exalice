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
      {@index_name, "location", UUID.uuid4(), Map.to_list(filter_doc(doc))}
    end)
  end

  defp prepare_doc(doc) do
    {@index_name, "location", UUID.uuid4(), Map.to_list(filter_doc(doc))}
  end

  defp filter_doc(%{"lat" => lat, "lon" => lon,
    "tags" =>
      %{"addr:city" => city, "addr:country" => country,
        "addr:housenumber" => housenumber, "addr:postcode" => postcode,
        "addr:street" => street}
    }) do

    %{lat: lat, lon: lon,
      location: %{city: city, state: country,
        street: street, housenumber: housenumber,
        postcode: postcode}}
  end

  defp filter_doc(%{lat: lat, lon: lon,
     location: %{city: city, country: country,
       housenumber: housenumber, state: state,
       postcode: postcode, street: street},
     }) do

    %{lat: lat, lon: lon,
      location: %{city: city, country: country,
        street: street, housenumber: housenumber,
        postcode: postcode, state: state}}
  end

  defp filter_doc(_) do
    %{}
  end

  defp index_docs(docs) do
    docs
    # Discard not "pure" docs :)
    |> Enum.filter(fn(x) -> Enum.at(Tuple.to_list(x), 3) != [] end)
    |> bulk_index
  end

  defp bulk_index(docs) do
    Tirexs.Bulk.store [index: @index_name, refresh: false], @settings, do: docs
  end
end
