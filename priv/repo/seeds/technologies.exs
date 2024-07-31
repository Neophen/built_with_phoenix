defmodule Seeds.Technologies do
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  def run() do
    [
      %Technology{
        name: "Nerves",
        url: "https://nerves-project.org/",
        image_url: nil
      },
      %Technology{
        name: "LiveView",
        url: "https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html",
        image_url: nil
      },
      %Technology{
        name: "Oban",
        url: "https://getoban.pro/",
        image_url: nil
      },
      %Technology{
        name: "Membrane",
        url: "https://membrane.stream/",
        image_url: nil
      },
      %Technology{
        name: "Nx",
        url: "https://github.com/elixir-nx/nx/tree/main/nx#readme",
        image_url: nil
      },
      %Technology{
        name: "Axon",
        url: "https://github.com/elixir-nx/axon?tab=readme-ov-file",
        image_url: nil
      },
      %Technology{
        name: "GenStage",
        url: "https://github.com/elixir-lang/gen_stage/tree/v1.2.1",
        image_url: nil
      },
      %Technology{
        name: "Broadway",
        url: "https://elixir-broadway.org/",
        image_url: nil
      },
      %Technology{
        name: "Bumblebee",
        url: "https://hexdocs.pm/bumblebee",
        image_url: nil
      }
    ]
    |> Enum.map(&Ash.Seed.seed!/1)
  end
end
