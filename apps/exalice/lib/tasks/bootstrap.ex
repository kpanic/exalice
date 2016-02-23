defmodule Mix.Tasks.Exalice.Bootstrap do
  use Application
  use Mix.Task
  @shortdoc "Bootstrap ExAlice"

  @doc """
  Bootstrap ExAlice by populating the "exalice" Elasticsearch index with sample
  data
  """

  def run(args) do
    Mix.Task.run("app.start", [])
    # FIXME: works only with fixed argument
    cond do
      args == [] ->
        ExAlice.Geocoder.Providers.Elastic.Importer.import
      args = [] ->
        ExAlice.Geocoder.Providers.Elastic.Importer.import(args)
      true ->
        IO.puts "ExAlice: Invalid argument"
    end
  end
end
