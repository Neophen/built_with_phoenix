defmodule BuiltWithPhoenixWeb.Admin.OrganizationLive.Index do
  use BuiltWithPhoenixWeb, :live_view

  require Ash.Query

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenixWeb.Admin.OrganizationLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid gap-8 p-8">
      <.header>
        Listing Organizations
        <:actions>
          <.link patch={~p"/admin/organizations/new"}>
            <.button>New Organization</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid-fill-cols-[256px] mt-6 grid gap-4">
        <div :for={organization <- @organizations} class="relative grid gap-2 rounded border p-4">
          <div class="absolute top-2 right-2">
            <p
              data-status={organization.status}
              class="status bg-[--status-bg] text-[--status-text] font-regular w-min rounded px-1 py-px text-xs uppercase leading-tight"
            >
              <%= organization.status %>
            </p>
          </div>
          <div class="flex items-center gap-4">
            <div class="flex h-12 w-12 items-center">
              <img src={organization.logo} class="h-auto w-full" />
            </div>

            <p class="font-semibold">
              <%= organization.name %>
            </p>
          </div>

          <p class="">
            <%= organization.url %>
          </p>

          <div class="flex gap-4">
            <.link
              patch={~p"/admin/organizations/#{organization}/edit"}
              class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            >
              Edit
            </.link>
            <button
              type="button"
              phx-click={JS.push("decline", value: %{id: organization.id})}
              class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-red-300 hover:bg-red-50"
            >
              Decline
            </button>
            <button
              type="button"
              phx-click={JS.push("approve", value: %{id: organization.id})}
              class="rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-green-300 hover:bg-green-50"
            >
              Approve
            </button>
          </div>
        </div>
      </div>
    </div>
    <.modal
      :if={@live_action in [:new, :edit]}
      show
      id="organization-modal"
      on_cancel={JS.patch(~p"/admin/organizations")}
    >
      <.live_component
        module={FormComponent}
        id={(@organization && @organization.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        organization={@organization}
        patch={~p"/admin/organizations"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_organizations()
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(
      :organization,
      Ash.get!(Organization, id, load: [:technologies], actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_info({FormComponent, {:saved, _organization}}, socket) do
    {:noreply, assign_organizations(socket)}
  end

  @impl true
  def handle_event("decline", %{"id" => id}, socket) do
    Ash.get!(Organization, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:decline)
    |> Ash.update!()

    {:noreply, assign_organizations(socket)}
  end

  def handle_event("approve", %{"id" => id}, socket) do
    Ash.get!(Organization, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:approve)
    |> Ash.update!()

    {:noreply, assign_organizations(socket)}
  end

  defp assign_organizations(socket) do
    assign(
      socket,
      :organizations,
      Organization
      |> Ash.Query.sort(:name)
      |> Ash.read!(actor: socket.assigns[:current_user])
    )
  end
end
