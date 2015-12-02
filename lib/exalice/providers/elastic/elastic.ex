defmodule ExAlice.Geocoder.Providers.Elastic do
  use HTTPoison.Base
  use Towel

  @index "exalice"

  def geocode(address) do
    search_query = %{
              query: %{
                  filtered: %{
                      query: %{
                          match: %{
                              _all: %{
                                  query: address
                              }
                          }
                      }
                  }
              }
          }

    {:ok, response} = :erlastic_search.search(@index, "location", search_query)
    parse_response(response["hits"]["hits"])
  end

  def parse_response(response, acc \\ []) do
    extract_sources(response, acc)
  end

  defp extract_sources([head|tail], acc) do
    extract_sources(tail, acc ++ [Dict.get(head, "_source")])
  end

  defp extract_sources([], acc) do
    acc
  end
end
