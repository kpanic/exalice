defmodule ExAlice.Geocoder.Providers.Elastic.Indexer do
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
        Stream.map([chunks], fn chunk ->
          Poison.decode!(chunk)
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
      # openstreetmap format without centroid
      %{
        "lat" => lat,
        "lon" => lon,
        "tags" => %{
          "addr:city" => city,
          "addr:country" => country,
          "addr:housenumber" => housenumber,
          "addr:postcode" => postcode,
          "addr:street" => street
        }
      } ->
        full_address = Enum.join([country, city, street, postcode, housenumber], " ")
        coordinates = %{lat: lat, lon: lon}
        location = %{full_address: full_address}

        Map.merge(coordinates, location)

      # openstreetmap format with centroid
      %{
        "centroid" => %{"lat" => lat, "lon" => lon},
        "tags" => %{
          "addr:city" => city,
          "addr:country" => country,
          "addr:housenumber" => housenumber,
          "addr:postcode" => postcode,
          "addr:street" => street
        }
      } ->
        full_address = Enum.join([country, city, street, postcode, housenumber], " ")
        coordinates = %{lat: lat, lon: lon}
        location = %{full_address: full_address}

        Map.merge(coordinates, location)

      # openstreetmap geocoder format
      %{lat: lat, lon: lon, full_address: full_address} ->
        coordinates = %{lat: lat, lon: lon}
        location = %{full_address: full_address}

        Map.merge(coordinates, location)

      # google maps format
      %{
        lat: lat,
        location: %{
          city: city,
          country: country,
          housenumber: housenumber,
          postcode: postcode,
          street: street
        },
        lon: lon
      } ->
        full_address = Enum.join([country, city, street, postcode, housenumber], " ")
        coordinates = %{lat: lat, lon: lon}
        location = %{full_address: full_address}

        Map.merge(coordinates, location)

      _default ->
        nil
    end
  end

  def index_docs(docs) do
    # Discard not "pure" docs :)
    docs
    |> discard_unparsable_docs
    |> bulk_index
  end

  defp discard_unparsable_docs(docs) do
    Stream.reject(docs, fn doc ->
      doc == nil
    end)
  end

  defp bulk_index(docs) do
    docs
    |> Enum.map(fn doc ->
      {Elastic.Index.name(@index_name), @doc_type, nil, doc}
    end)
    |> Elastic.Bulk.create()
  end
end
