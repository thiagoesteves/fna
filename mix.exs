defmodule FnaApp.MixProject do
  use Mix.Project

  @source_url "https://github.com/thiagoesteves/fna"

  def project do
    [
      app: :fna_app,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "fna_app",
      description: description(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Do not start application during the tests
  defp aliases do
    [
      "ecto.setup": ["ecto.create -r Fna.Repo", "ecto.migrate -r Fna.Repo"],
      "ecto.reset": ["ecto.drop -r Fna.Repo", "ecto.setup"],
      test: ["ecto.reset", "test --no-start"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gproc, :inets, :ecto],
      mod: {Fna.Application, []}
    ]
  end

  defp description do
    "Forza Football Home assignment for Senior Backend Developer"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, git:  "git://github.com/uwiger/gproc"},
      {:flow,        "~> 0.14.0"},
      {:poison,      "~> 3.1"},
      {:ecto_sql,    "~> 3.0"},
      {:postgrex,    ">= 0.0.0"},
      {:dialyxir,    "~> 1.0",  only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
    ]
  end
end
