# ExAlice

**WARNING: This is alpha software, do not use in production!**

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

  3. Ensure that Elasticsearch 2.2.x is running

  4. To run the import:

        mix exalice.bootstrap # Populate the storage with sample data in this repository

To geocode:

    mix run -e "ExAlice.Geocoder.geocode(\"Via Recoaro 3, Broni\")"

**NOTE**: At the moment the geocoder relies on google maps and there's no
possibility to use a google maps api key.
