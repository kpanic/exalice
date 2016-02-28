use Mix.Config

import_config "#{Mix.env}.exs"


config :exalice,
  provider: ExAlice.Geocoder.Providers.Elastic,
  geocoder: ExAlice.Geocoder.Providers.OpenStreetMap
