defmodule AuthorizeNet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixir_authorizenet,
      name: "elixir_authorizenet",
      source_url: "https://github.com/marcelog/elixir_authorizenet",
      version: "0.1.1",
      elixir: "> 1.0.0",
      description: description,
      package: package,
      deps: deps
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :ibrowse
      ]
    ]
  end

  defp description do
    """
Elixir client for the Authorize.Net merchant API. This should help you integrate using the AIM.

A nice number of features are implemented (probably most of the ones used
on a daily basis are already there), but since the API offers a big number of
features and combinations, I still consider this as WIP, and pull requests,
suggestions, or other kind of feedback are very welcome!

Find the user guide in the github repo at: https://github.com/marcelog/elixir_authorizenet.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      contributors: ["Marcelo Gornstein"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/marcelog/elixir_authorizenet"
      }
    ]
  end

  defp deps do
    [
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev},
      {:coverex, "~> 1.2.0", only: :test},
      {:exmerl, "~> 0.1.1"},
      {:xml_builder, "~> 0.0.6"},
      {:servito, github: "marcelog/servito", only: :test}
    ]
  end
end
