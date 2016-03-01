defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  import Tirexs.Bulk
  require Tirexs.ElasticSearch


  def index(documents) do
    documents
    |> json_decode
    |> prepare_doc
    |> index_docs
  end

  def json_decode(chunks) do
    cond do
      is_list(chunks) ->
        Enum.map(chunks, fn chunk ->
          if is_map(chunk) do
            chunk
          else
            Poison.decode!(chunk)
          end
        end)

      true ->
        Enum.map(chunks, fn chunk ->
          chunk = String.strip(Enum.join(chunk, ","), ?,)
          Poison.decode! "[" <> chunk <> "]"
        end)
    end
  end

  def prepare_doc(docs) do
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
          "addr:street" => street}} ->

            full_address = Enum.join(
              [country, city, street, postcode, housenumber], " ")
            coordinates = [lat: lat, lon: lon]
            location = [full_address: full_address]
            metadata = [type: "location"]
            doc = metadata ++ coordinates ++ location
            [index: doc]

      # openstreetmap geocoder format
      %{lat: lat, lon: lon,
        full_address: full_address} ->
          coordinates = [lat: lat, lon: lon]
          location = [full_address: full_address]
          metadata = [type: "location"]
          doc = metadata ++ coordinates ++ location
          [index: doc]

      # google maps format
      %{lat: lat,
        location: %{city: city, country: country, housenumber: housenumber,
                    postcode: postcode, state: region, street: street},
         lon: lon} ->

        full_address = Enum.join(
          [country, city, street, postcode, housenumber], " ")
        coordinates = [lat: lat, lon: lon]
        location = [full_address: full_address]
        metadata = [type: "location"]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      _ ->
        metadata = [type: "location"]
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
    docs = Enum.reject(docs, fn doc ->
      values = Keyword.get_values(doc, :index)
      Enum.count(List.first(values)) == 1
    end)
  end

  defp bulk_index(docs) do
    settings = Tirexs.ElasticSearch.config()
    index_name = ExAlice.Geocoder.config(:index)

    Tirexs.Bulk.store [index: index_name, refresh: false], settings, do: docs
  end
end
