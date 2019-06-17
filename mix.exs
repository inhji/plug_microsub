defmodule PlugMicrosub.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_microsub,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "PlugMicrosub",
      description: "A plug for building a Microsub server.",
      source_url: "https://github.com/inhji/plug_microsub",
      docs: [main: "readme", extras: ["README.md"]],
      package: [
        name: "plug_microsub",
        licenses: ["BSD 3-Clause"],
        maintainers: ["Jonathan Jenne"],
        links: %{github: "https://github.com/inhji/plug_microsub"}
      ]
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
      {:plug, "~> 1.5"},
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false}
    ]
  end
end
