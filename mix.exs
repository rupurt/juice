defmodule Juice.MixProject do
  use Mix.Project

  def project do
    [
      app: :juice,
      version: "0.0.2",
      elixir: "~> 1.6",
      package: package(),
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Reduce in memory data structures using a lightweight query language"
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Alex Kwiatkowski"],
      links: %{"GitHub" => "https://github.com/rupurt/juice"}
    }
  end
end
