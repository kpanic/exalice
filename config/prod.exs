use Mix.Config

config :exalice,
  index: :exalice,
  doc_type: :location,
  capacity: 4,
  file: "data/germany-streets.json",
  chunks: 5000
