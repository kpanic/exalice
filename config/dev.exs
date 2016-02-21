use Mix.Config

config :exalice,
  index: :exalice,
  doc_type: :location,
  file: "data/germany-streets.json",
  chunks: 5000
