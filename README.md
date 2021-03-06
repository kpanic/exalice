# ExAlice

[![Build Status](https://travis-ci.org/kpanic/exalice.svg?branch=master)](https://travis-ci.org/kpanic/exalice)

![Alice in wonderland!](/pic/alice-in-wonderland.png)

**WARNING: This is alpha software, do not use in production!**

## Installation of exalice from this repository

  1. Ensure that Elasticsearch 6.4.0 is installed

  2. Ensure that the analysis-icu plugin is installed:

```bash
# On Debian based systems
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu
```

    The path of the `plugin` command varies between different operating systems

  3. Ensure that Elasticsearch is started

  4. Run the import (after fetching deps, and compiling everything):

```bash
mix exalice.bootstrap # Populate the storage with sample data in this repository
```

## When exalice is used as an external dependency in your application

  1. Add exalice to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exalice, "~> 0.0.7-alpha"}]
end
```

  2. Ensure that Elasticsearch 6.4.0 is installed

  3. Ensure that the analysis-icu plugin is installed:

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu
```

    The path might vary between different operating systems

  4. Ensure that Elasticsearch is started

  5. Add to your config/config.exs:

```elixir
config :exalice,
      provider: ExAlice.Geocoder.Providers.Elastic,
      geocoder: ExAlice.Geocoder.Providers.OpenStreetMap,
      index: :exalice,
      doc_type: :location,
      file: "data/germany-streets.json",
      chunks: 5000
```

    The available options for the `geocoder:` are
    `ExAlice.Geocoder.Providers.GoogleMaps` or
    `ExAlice.Geocoder.Providers.OpenStreetMap`

  7. (optional) Put a json file generated with [pbf2json](https://github.com/pelias/pbf2json) from openstreetmap pbf(s) in your `data/` folder

  8. Copy the [germany-streets.json](https://github.com/kpanic/exalice/blob/master/data/germany-streets.json) sample extract in your local `data/` folder inside your application

  9. Run `mix exalice.bootstrap`



## To geocode an address execute:

  1. Run `iex -S mix`

  2. Type `ExAlice.Geocoder.geocode("Via Recoaro 3, Broni")`

  3. You should receive back data from the configured geocoder provider
     (OpenStreetMap or Google Maps)

  4. If you run again `ExAlice.Geocoder.geocode("Via Recoaro, Broni")` you should receive back data from the storage (no external lookup)

**NOTE**: At the moment the geocoder part that relies on google maps has no
possibility to use a google maps api key.
