defmodule BuiltWithPhoenixWeb.Admin.TechnologyLive.Index do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Technology
  alias BuiltWithPhoenixWeb.Admin.TechnologyLive.FormComponent

  alias Phoenix.LiveView

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.header>
      Listing Technologies
      <:actions>
        <.link patch={~p"/admin/technologies/new"}>
          <.button>New Technology</.button>
        </.link>
      </:actions>
    </.header>

    <div class="grid-fill-cols-[256px] mt-6 grid gap-4">
      <div :for={technology <- @technologies} class="relative grid gap-2 rounded border p-4">
        <div class="absolute top-2 right-2">
          <p
            data-status={technology.status}
            class="status bg-[--status-bg] text-[--status-text] font-regular w-min rounded px-1 py-px text-xs uppercase leading-tight"
          >
            {technology.status}
          </p>
        </div>
        <div class="flex items-center gap-4">
          <div class="flex h-12 w-12 items-center">
            <img src={technology.logo} class="h-auto w-full" />
          </div>

          <p class="font-semibold">
            {technology.name}
          </p>
        </div>

        <p class="truncate" title={technology.url}>
          {technology.url}
        </p>

        <div class="flex gap-4">
          <.link
            patch={~p"/admin/technologies/#{technology}/edit"}
            class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            Edit
          </.link>
          <button
            type="button"
            phx-click={JS.push("decline", value: %{id: technology.id})}
            class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-red-300 hover:bg-red-50"
          >
            Decline
          </button>
          <button
            type="button"
            phx-click={JS.push("approve", value: %{id: technology.id})}
            class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-green-300 hover:bg-green-50"
          >
            Approve
          </button>
        </div>
      </div>
    </div>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="technology-modal"
      show
      on_cancel={JS.patch(~p"/admin/technologies")}
    >
      <.live_component
        module={FormComponent}
        id={(@technology && @technology.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        technology={@technology}
        patch={~p"/admin/technologies"}
      />
    </.modal>
    """
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_technologies()
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Technology")
    |> assign(
      :technology,
      Ash.get!(Technology, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Technology")
    |> assign(:technology, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Technologies")
    |> assign(:technology, nil)
  end

  @impl LiveView
  def handle_info({FormComponent, {:saved, _organization}}, socket) do
    {:noreply, assign_technologies(socket)}
  end

  @impl LiveView
  def handle_event("decline", %{"id" => id}, socket) do
    Ash.get!(Technology, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:decline)
    |> Ash.update!()

    {:noreply, assign_technologies(socket)}
  end

  def handle_event("approve", %{"id" => id}, socket) do
    Ash.get!(Technology, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:approve)
    |> Ash.update!()

    {:noreply, assign_technologies(socket)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    technology =
      Ash.get!(Technology, id, actor: socket.assigns.current_user)

    Ash.destroy!(technology, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :technologies, technology)}
  end

  defp assign_technologies(socket) do
    assign(
      socket,
      :technologies,
      Technology
      |> Ash.Query.sort(:name)
      |> Ash.read!(actor: socket.assigns[:current_user])
    )
  end
end
