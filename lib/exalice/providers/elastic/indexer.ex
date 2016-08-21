defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
  import Tirexs.Bulk

  @index_name ExAlice.Geocoder.config(:index)
  @doc_type ExAlice.Geocoder.config(:doc_type)

  def index(documents) do
    documents
    |> json_decode
    |> prepare_doc
    |> index_docs
  end

  def json_decode(chunks) do
    cond do
      is_list(chunks) ->
        Stream.map(chunks, fn chunk ->
          if is_map(chunk) do
            chunk
          else
            Poison.decode!(chunk)
          end
        end)
      true ->
        Stream.map(Enum.into(chunks, []), fn chunk ->
          Poison.decode! chunk
        end)
    end
  end

  def prepare_doc(docs) do
    Stream.map(Enum.into(docs, []), fn doc ->
      filter_doc(doc)
    end)
  end

  defp filter_doc(doc) do
    case doc do
      # openstreetmap format without centroid
      %{"lat" => lat, "lon" => lon,
        "tags" =>
          %{"addr:city" => city, "addr:country" => country,
            "addr:housenumber" => housenumber, "addr:postcode" => postcode,
            "addr:street" => street}
      } ->

        full_address = Enum.join(
          [country, city, street, postcode, housenumber], " ")
        coordinates = [lat: lat, lon: lon]
        location = [full_address: full_address]
        metadata = [type: @doc_type]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      # openstreetmap format with centroid
      %{"centroid" => %{"lat" => lat, "lon" => lon},
        "tags" =>
          %{"addr:city" => city, "addr:country" => country,
            "addr:housenumber" => housenumber, "addr:postcode" => postcode,
            "addr:street" => street}
      } ->

          full_address = Enum.join(
            [country, city, street, postcode, housenumber], " ")
          coordinates = [lat: lat, lon: lon]
          location = [full_address: full_address]
          metadata = [type: @doc_type]
          doc = metadata ++ coordinates ++ location
          [index: doc]

      # openstreetmap geocoder format
      %{lat: lat, lon: lon, full_address: full_address} ->

          coordinates = [lat: lat, lon: lon]
          location = [full_address: full_address]
          metadata = [type: @doc_type]
          doc = metadata ++ coordinates ++ location
          [index: doc]

      # google maps format
      %{lat: lat,
        location: %{
          city: city, country: country, housenumber: housenumber,
          postcode: postcode, street: street
        },
        lon: lon} ->

        full_address = Enum.join(
          [country, city, street, postcode, housenumber], " ")
        coordinates = [lat: lat, lon: lon]
        location = [full_address: full_address]
        metadata = [type: @doc_type]
        doc = metadata ++ coordinates ++ location
        [index: doc]

      _ ->
        metadata = [type: @doc_type]
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
      [index: values] = doc
      Enum.count(values) == 1
    end)
  end

  defp bulk_index(docs) do

    payload = Tirexs.Bulk.bulk do
      Tirexs.Bulk.index [index: @index_name, type: @doc_type], docs
    end

    unless Enum.empty?(docs) do
      {:ok, 200, r} = Tirexs.bump!(payload)._bulk()
    end
  end
end
