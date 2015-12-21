defmodule ExAlice.Mixfile do
  use Mix.Project

  def project do
    [app: :exalice,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison],
     mod: {ExAlice, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 1.5.0"},
      {:httpoison, "~> 0.8"},
      {:hackney, "~> 1.4.4", [optional: false, hex: :hackney, override: true]},
      {:towel, "~> 0.2"},
      {:uuid, "~> 1.1.1"},
      {:credo, "~> 0.1.9", only: [:dev, :test]},
      {:tirexs, "~> 0.7.3"}
    ]
  end
end
