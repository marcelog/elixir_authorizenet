defmodule AuthorizeNet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixir_authorizenet,
      name: "elixir_authorizenet",
      source_url: "https://github.com/marcelog/elixir_authorizenet",
      version: "0.4.0",
      elixir: ">= 1.0.0",
      description: description(),
      package: package(),
      deps: deps()
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
      maintainers: ["Marcelo Gornstein"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/marcelog/elixir_authorizenet"
      }
    ]
  end

  defp deps do
    [
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.3"},
      {:earmark, "~> 1.0.3", only: :dev},
      {:ex_doc, "~> 0.14.5", only: :dev},
      {:coverex, "~> 1.4.12", only: :test},
      {:exmerl, github: "portatext/exmerl", branch: "fixing_warnings_elixir_1_4_0"},
      {:xml_builder, "~> 0.0.9"},
      {:servito, github: "marcelog/servito", only: :test, tag: "v0.0.10"}
    ]
  end
end
