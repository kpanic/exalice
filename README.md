# ExAlice

**WARNING: this is just one of my elixir playground, play with it at your own RISK! It might break your IoT devices! ;)**

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

Run these commands:

    curl -XDELETE localhost:9200/exalice/?refresh=true

    curl -XPOST localhost:9200/exalice?refresh=true -d '{ "index" : { "refresh_interval" : "-1" } }'

To run the import:

    mix exalice.bootstrap # with sample data

    mix run -e "ExAlice.Geocoder.Providers.Elastic.Importer.import(\"world-streets-full.json\")" # with your data

To geocode:

    mix run -e "ExAlice.Geocoder.geocode(\"Via Recoaro 3, Broni\")"
