defmodule Ammo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ammotion,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ammo.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth, :arc_ecto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      {:jason, "~> 1.0.0-rc.1"},
      {:exexif, "~> 0.0"},
      {:geo, "~> 2.0"},
      {:geo_postgis, "~> 1.0"},

      {:arc, "~> 0.8"},
      {:arc_ecto, "~> 0.7"},

      {:ueberauth, "~> 0.5"},
      {:oauth2, "~> 0.8", override: true},
      {:oauth, github: "tim/erlang-oauth"},
      {:ueberauth_facebook, "~> 0.5"},
      {:ueberauth_google, "~> 0.5"},
      {:ueberauth_github, "~> 0.4"},
      {:ueberauth_identity, "~> 0.2"},
      {:ueberauth_slack, "~> 0.4"},
      {:ueberauth_twitter, "~> 0.2"},
      {:poison, "~> 3.0", override: true},

      {:dogma, ">= 0.0.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
