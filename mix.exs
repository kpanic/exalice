defmodule ExAlice.Mixfile do
  use Mix.Project

  def project do
    [app: :exalice,
     version: "0.0.1-alpha",
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
      {:poison, "~> 2.1.0"},
      {:httpoison, "~> 0.8"},
      {:hackney, "~> 1.4.4", [optional: false, hex: :hackney, override: true]},
      {:towel, "~> 0.2"},
      {:tirexs, "~> 0.7.6"}
    ]
  end
end
