# ExAlice

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exalice to your list of dependencies in `mix.exs`:

        def deps do
          [{:exalice, "~> 0.0.1"}]
        end

  2. Ensure exalice is started before your application:

        def application do
          [applications: [:exalice]]
        end

  3. Ensure that Elasticsearch is running

To run the import:

    mix run -e "ExAlice.Geocoder.Providers.Elastic.Importer.import([])"

To geocode:

    mix run -e "ExAlice.Geocoder.geocode(\"A Sunny Street, 2, Everywhere\")"

NOTE: mapping in Elasticsearch are not yet present, results may vary after
geocoding the first time :)
