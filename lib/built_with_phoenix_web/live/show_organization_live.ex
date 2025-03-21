defmodule BuiltWithPhoenixWeb.ShowOrganizationLive do
  use BuiltWithPhoenixWeb, :live_view
  alias BuiltWithPhoenix.Organizations.Resource.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-12 grid min-w-0 gap-12 md:grid-cols-[300px_1fr]">
      <div class="min-w-0">
        <ul class="grid min-w-0 gap-8">
          <li class="flex flex-wrap items-center gap-2">
            <div class="rounded border bg-white p-2">
              <img class="h-12" src={imgproxy(@organization.logo, "h:48")} alt="" />
            </div>
            <.text_header>{@organization.name}</.text_header>
          </li>
          <li :if={@organization.description}>
            <.p class="text-pretty font-sans break-normal font-normal">
              {@organization.description}
            </.p>
          </li>
          <li>
            <.p>How do we know they use phoenix:</.p>
            <.p class="text-pretty font-sans break-normal font-semibold">
              {@organization.usage_public}
            </.p>
          </li>
          <li>
            <.p>Extra Sites:</.p>
            <.p class="text-pretty font-sans break-normal font-semibold">
              {@organization.extra_sites}
            </.p>
          </li>
          <li class="pt-4">
            <a
              href={@organization.url}
              class="bg-primary-500 flex items-center justify-between gap-2 rounded-md px-4 py-3 text-white transition-colors hover:bg-primary-600"
            >
              <span>Visit website</span>

              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"
                />
              </svg>
            </a>
          </li>
        </ul>
      </div>
      <div class=" h-[364px] row-start-1 min-w-0 drop-shadow-md md:row-start-auto">
        <img
          src={imgproxy(@organization.image, "size:644:364")}
          class="aspect-video rounded-xl"
          alt=""
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    organization = Organization.get_by_id!(id)

    {:noreply,
     socket
     |> assign(:page_title, organization.name)
     |> assign(:organization, organization)}
  end
end
