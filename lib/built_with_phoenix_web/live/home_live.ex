defmodule BuiltWithPhoenixWeb.HomeLive do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  alias Phoenix.LiveView

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-lg pt-12 pb-32">
      <.hero />

      <ul class="mt-12 flex flex-wrap justify-center">
        <li key="all">
          <button
            data-active={is_nil(@technology_id)}
            type="button"
            class="border-b-2 border-slate-500 px-3 py-1 text-slate-500 data-[active]:border-orange-500 data-[active]:text-slate-900"
            phx-click="remove-technology"
          >
            <%= dgettext("home.html", "All Technologies") %>
          </button>
        </li>
        <li :for={technology <- @technologies} key={technology.id}>
          <button
            data-active={technology.id == @technology_id}
            type="button"
            class="border-b-2 border-slate-500 px-3 py-1 text-slate-500 data-[active]:border-orange-500 data-[active]:text-slate-900"
            phx-click="select-technology"
            phx-value-id={technology.id}
          >
            <%= technology.name %>
          </button>
        </li>
      </ul>

      <ul class="grid-fill-cols-[256px] mt-6 grid gap-4">
        <li>
          <.organization_card url="https://marko.ch" organization="marko" />
        </li>
        <li>
          <.organization_card url="https://electric-sql.com" organization="electric-sql" />
        </li>
        <li>
          <.organization_card url="https://www.liveflow.io" organization="liveflow" />
        </li>
        <li>
          <.organization_card url="https://liveroom.app" organization="liveroom" />
        </li>
        <li>
          <.organization_card url="https://remote.com" organization="remote" />
        </li>
        <li>
          <.organization_card url="https://savvycal.com" organization="savvycal" />
        </li>
        <li>
          <.organization_card url="https://supabase.com" organization="supabase" />
        </li>
        <li>
          <.organization_card url="https://techschool.dev" organization="techschool" />
        </li>
      </ul>

      <.footer />
    </div>
    """
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:technology_id, nil)
     |> assign(:technologies, Ash.read!(Technology))
     |> stream(:organizations, Ash.read!(Organization))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl LiveView
  def handle_event("select-technology", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:technology_id, id)}
  end

  def handle_event("remove-technology", _params, socket) do
    {:noreply,
     socket
     |> assign(:technology_id, nil)}
  end

  defp footer(assigns) do
    ~H"""
    <footer id="about" class="bg-white px-6 py-24 sm:py-32 lg:px-8">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">About</h2>
        <.p class="text-pretty mt-6 text-lg leading-8 text-gray-600">
          This is a manually curated list of companies and organizations using Phoenix, with an emphasis on showing real-life projects, not just developer-focused tools and sites. Our goal isn't to get as many sites in here as possible; it's to show people who are unsure about Phoenix what it can be used for.
        </.p>
      </div>
    </footer>
    """
  end
end
