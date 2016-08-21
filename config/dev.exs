use Mix.Config

config :exalice,
  index: "exalice",
  doc_type: :location,
  capacity: 4,
  file: "data/germany-streets.json",
  chunks: 5000

config :tirexs, :uri, "http://127.0.0.1:9200"
