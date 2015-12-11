defmodule Mix.Tasks.Exalice.Bootstrap do
  use Application
  use Mix.Task
  @shortdoc "Bootstrap ExAlice"

  @doc """
  Bootstrap ExAlice by populating the "exalice" Elasticsearch index with sample
  data
  """

  def run(args) do
    # NOTE: Hackney has to be started manually in the task
    # it seems that mix.exs is not honoured, hackney should be started by
    # :erlastic_search since it's a dependency of it?
    :hackney.start()

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
