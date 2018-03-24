defmodule ExAliceTest do
  use ExUnit.Case

  import ExAlice.Geocoder.Providers.Elastic.Importer, only: [chunk: 2]

  setup_all do
    {:ok, data: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]}
  end

  test "expect that the chunks are split correctly", meta do
    # total chunks are 10 in data/test-data.json
    chunk_number = 2

    res = chunk(meta[:data], chunk_number)

    assert Enum.count(res) == 5
  end

  test "expect that \"oversize\" chunks are split correctly", meta do
    # total chunks are 10 in data/test-data.json
    chunk_number = 100

    res = chunk(meta[:data], chunk_number)

    assert Enum.count(res) == 1
  end
end
