defmodule BuiltWithPhoenixWeb.OrganizationLive.Index do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid gap-8 p-8">
      <.header>
        Listing Organizations
        <:actions>
          <.link patch={~p"/organizations/new"}>
            <.button>New Organization</.button>
          </.link>
        </:actions>
      </.header>

      <.table
        id="organizations"
        rows={@streams.organizations}
        row_click={fn {_id, organization} -> JS.navigate(~p"/organizations/#{organization}") end}
      >
        <:col :let={{_id, organization}} label="Name"><%= organization.name %></:col>

        <:col :let={{_id, organization}} label="Url"><%= organization.url %></:col>
        <:col :let={{_id, organization}} label="Status"><%= organization.status %></:col>

        <:col :let={{_id, organization}} label="">
          <div class="flex w-min items-center gap-2">
            <div class="sr-only">
              <.link navigate={~p"/organizations/#{organization}"}>Show</.link>
            </div>

            <.link patch={~p"/organizations/#{organization}/edit"}>Edit</.link>
            <.button
              phx-click={JS.push("approve", value: %{id: organization.id})}
              data-confirm="Are you sure, you want to approve this?"
            >
              Approve
            </.button>
            <.button
              phx-click={JS.push("decline", value: %{id: organization.id})}
              data-confirm="Are you sure, you want to decline this?"
            >
              Decline
            </.button>
          </div>
        </:col>
      </.table>
    </div>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="organization-modal"
      on_cancel={JS.patch(~p"/organizations")}
    >
      <.live_component
        module={BuiltWithPhoenixWeb.OrganizationLive.FormComponent}
        id={(@organization && @organization.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        organization={@organization}
        patch={~p"/organizations"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :organizations,
       Ash.read!(Organization,
         actor: socket.assigns[:current_user]
       )
     )
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
      Ash.get!(Organization, id, actor: socket.assigns.current_user)
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
  def handle_info(
        {BuiltWithPhoenixWeb.OrganizationLive.FormComponent, {:saved, organization}},
        socket
      ) do
    {:noreply, stream_insert(socket, :organizations, organization)}
  end

  @impl true
  def handle_event("decline", %{"id" => id}, socket) do
    Ash.get!(Organization, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:decline)
    |> Ash.update!()

    {:noreply, socket}
  end

  def handle_event("approve", %{"id" => id}, socket) do
    # providing an initial ticket to close

    Ash.get!(Organization, id, actor: socket.assigns.current_user)
    |> Ash.Changeset.for_update(:approve)
    |> Ash.update!()

    {:noreply, socket}
  end
end
