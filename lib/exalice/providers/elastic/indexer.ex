defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  import Tirexs.Bulk
  require Tirexs.ElasticSearch

  @settings Tirexs.ElasticSearch.config()

  require UUID

  @index_name ExAlice.Geocoder.config(:index)

  def index(documents) do
    documents
    |> json_decode
    |> prepare_doc
    |> index_docs
  end

  def json_decode(chunks) do
    if is_list(chunks) do
      chunks = List.flatten(chunks)
      Enum.map(chunks, fn chunk -> Poison.decode!(chunk) end)
    else
      Enum.map(chunks, fn chunk ->
        chunk = String.strip(Enum.join(chunk, ","), ?,)
        Poison.decode! "[" <> chunk <> "]"
      end)
    end
  end

  def prepare_doc(docs) do
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

        full_address = Enum.join(
          [country, city, street, postcode, housenumber], " ")
        coordinates = [lat: lat, lon: lon]
        location = [location: [city: city,
            street: street, housenumber: housenumber,
            postcode: postcode, state: country,
            full_address: full_address]]
        metadata = [type: "location", _id: UUID.uuid4()]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      # geocoder format
      %{lat: lat, lon: lon,
        location: %{city: city, country: country,
          housenumber: housenumber, state: state,
          postcode: postcode, street: street}} ->

        full_address = Enum.join(
          [country, city, street, postcode, housenumber, state], " ")
        coordinates = [lat: lat, lon: lon]
        location = [location: [city: city,
            street: street, housenumber: housenumber,
            postcode: postcode, state: country,
            full_address: full_address]]
        metadata = [type: "location", _id: UUID.uuid4()]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      _ ->
        metadata = [type: "location", _id: UUID.uuid4()]
        [index: metadata]
    end
  end

  def index_docs(docs) do
    docs
    # Discard not "pure" docs :)
    |> discard_unparsable_docs
    |> bulk_index
  end

  defp discard_unparsable_docs(docs) do
    Enum.reject(docs, fn doc ->
      values = Keyword.get_values(doc, :index)
      Enum.count(List.flatten(values)) == 2
    end)
  end

  defp bulk_index(docs) do
    Tirexs.Bulk.store [index: @index_name, refresh: false], @settings, do: docs
  end
end
