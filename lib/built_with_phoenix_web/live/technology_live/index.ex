defmodule BuiltWithPhoenixWeb.TechnologyLive.Index do
  use BuiltWithPhoenixWeb, :live_view

  @impl true
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

    <.table
      id="technologies"
      rows={@streams.technologies}
      row_click={fn {_id, technology} -> JS.navigate(~p"/admin/technologies/#{technology}") end}
    >
      <:col :let={{_id, technology}} label="Id"><%= technology.id %></:col>

      <:col :let={{_id, technology}} label="Name"><%= technology.name %></:col>

      <:col :let={{_id, technology}} label="Url"><%= technology.url %></:col>

      <:col :let={{_id, technology}} label="Image url"><%= technology.image_url %></:col>

      <:action :let={{_id, technology}}>
        <div class="sr-only">
          <.link navigate={~p"/admin/technologies/#{technology}"}>Show</.link>
        </div>

        <.link patch={~p"/admin/technologies/#{technology}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, technology}}>
        <.link
          phx-click={JS.push("delete", value: %{id: technology.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="technology-modal"
      show
      on_cancel={JS.patch(~p"/admin/technologies")}
    >
      <.live_component
        module={BuiltWithPhoenixWeb.TechnologyLive.FormComponent}
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

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :technologies,
       Ash.read!(BuiltWithPhoenix.Organizations.Resource.Technology,
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
    |> assign(:page_title, "Edit Technology")
    |> assign(
      :technology,
      Ash.get!(BuiltWithPhoenix.Organizations.Resource.Technology, id,
        actor: socket.assigns.current_user
      )
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

  @impl true
  def handle_info(
        {BuiltWithPhoenixWeb.TechnologyLive.FormComponent, {:saved, technology}},
        socket
      ) do
    {:noreply, stream_insert(socket, :technologies, technology)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    technology =
      Ash.get!(BuiltWithPhoenix.Organizations.Resource.Technology, id,
        actor: socket.assigns.current_user
      )

    Ash.destroy!(technology, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :technologies, technology)}
  end
end
