defmodule EOD.Mixfile do
  use Mix.Project

  def project do
    [app: :eve_of_darkness,
     version: "0.1.0",
     elixir: "~> 1.5",
     elixirc_paths: elixir_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto, :postgrex, :ecto_sql],
     mod: {EOD, []}]
  end

  defp elixir_paths(:test), do: ~w(lib test/support)
  defp elixir_paths(_),     do: ~w(lib)

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
    [{:ecto, "~> 3.0.0"},
     {:ecto_sql, "~> 3.0.0"},
     {:postgrex, ">= 0.0.0"},
     {:comeonin, "~> 4.0"},
     {:pbkdf2_elixir, "~> 0.12"},

     # Test Only Dependencies
     {:ex_machina, "~> 2.2", only: :test},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false}]
  end
end
