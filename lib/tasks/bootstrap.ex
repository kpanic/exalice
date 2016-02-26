defmodule Mix.Tasks.Exalice.Bootstrap do
  use Application
  use Mix.Task
  @shortdoc "Bootstrap ExAlice"

  @doc """
  Bootstrap ExAlice by populating the "exalice" Elasticsearch index with sample
  data
  """

  def run(_) do
    Mix.Task.run("app.start", [])
    # FIXME: works only with fixed argument
    ExAlice.Geocoder.Providers.Elastic.Importer.import
  end
end
