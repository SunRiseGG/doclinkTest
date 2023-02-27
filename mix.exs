defmodule TestTask.Mixfile do
  use Mix.Project

  def project do
    [
      app: :testTask,
      version: "0.0.1",
      description: "Test Task",
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [mod: {TestTask.Application, []}, applications: [:logger, :n2o, :rocksdb, :cowboy, :ranch, :kvs, :nitro, :bpe, :mnesia]]
  end

  def package do
    [
      files: ~w(lib mix.exs),
      licenses: ["ISC"],
      maintainers: ["SunRiseGG"],
      name: :testTask,
      links: %{"GitHub" => "https://github.com/SunRiseGG/testTask"}
    ]
  end

  def deps do
    [
      {:ex_doc, "~> 0.11", only: :dev},
      {:bpe, "7.10.4"},
      {:rocksdb, "1.6.0"},
      {:kvs, "9.9.0", override: true},
      {:nitro, "7.12.1", override: true},
      {:n2o, "~> 9.11.1"},
      {:cowboy, "~> 2.9.0", override: true},
      {:cowlib, "~> 2.11.0", override: true},
      {:elixir_make, "~> 0.6.0", runtime: false}
    ]
  end
end