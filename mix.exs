defmodule EctoStorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_storage,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.13"},
      {:plug, "~> 1.0"},
      {:phoenix, "~> 1.7"},
      {:igniter, "~> 0.6.28", only: [:dev, :test]}
    ]
  end
end
