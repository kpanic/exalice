defmodule ExAlice.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exalice,
      version: "0.0.7-alpha",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :elastic]]
  end

  defp deps() do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0.0"},
      {:elastic, "~> 3.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    """
    ExAlice, a geocoder with swappable storage
    """
  end

  defp package() do
    [
      files: [
        "config",
        "data/germany-streets.json",
        "data/test-data.json",
        "lib",
        "LICENSE",
        "mix.exs",
        "mix.lock",
        "README.md"
      ],
      maintainers: ["Marco Milanesi"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/kpanic/exalice",
        "Contributors" => "https://github.com/kpanic/exalice/graphs/contributors",
        "Issues" => "https://github.com/kpanic/exalice/issues"
      }
    ]
  end
end
