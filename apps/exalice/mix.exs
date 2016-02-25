defmodule ExAlice.Mixfile do
  use Mix.Project

  def project do
    [app: :exalice,
     version: "0.0.1-alpha",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end


  def application do
    [applications: [:logger, :httpoison, :tirexs],
     mod: {ExAlice, []}]
  end

  defp deps do
    [
      {:poison, "~> 1.5.0"},
      {:httpoison, "~> 0.8"},
      {:hackney, "~> 1.4.4", [optional: false, hex: :hackney, override: true]},
      {:towel, "~> 0.2"},
      {:tirexs, "~> 0.7.4"}
    ]
  end
end
