defmodule Seeds.Technologies do
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  def run() do
    [
      %Technology{
        name: "Nerves",
        url: "https://nerves-project.org/",
        logo: nil
      },
      %Technology{
        name: "LiveView",
        url: "https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html",
        logo: nil
      },
      %Technology{
        name: "Oban",
        url: "https://getoban.pro/",
        logo: nil
      },
      %Technology{
        name: "Membrane",
        url: "https://membrane.stream/",
        logo: nil
      },
      %Technology{
        name: "Nx",
        url: "https://github.com/elixir-nx/nx/tree/main/nx#readme",
        logo: nil
      },
      %Technology{
        name: "Axon",
        url: "https://github.com/elixir-nx/axon?tab=readme-ov-file",
        logo: nil
      },
      %Technology{
        name: "GenStage",
        url: "https://github.com/elixir-lang/gen_stage/tree/v1.2.1",
        logo: nil
      },
      %Technology{
        name: "Broadway",
        url: "https://elixir-broadway.org/",
        logo: nil
      },
      %Technology{
        name: "Bumblebee",
        url: "https://hexdocs.pm/bumblebee",
        logo: nil
      }
    ]
    |> Enum.map(&Ash.Seed.seed!/1)
  end
end
