defmodule BuiltWithPhoenixWeb.TechnologyLive.Show do
  use BuiltWithPhoenixWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Technology <%= @technology.id %>
      <:subtitle>This is a technology record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/technologies/#{@technology}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit technology</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @technology.id %></:item>

      <:item title="Name"><%= @technology.name %></:item>

      <:item title="Url"><%= @technology.url %></:item>

      <:item title="Image url"><%= @technology.image_url %></:item>
    </.list>

    <.back navigate={~p"/technologies"}>Back to technologies</.back>

    <.modal
      :if={@live_action == :edit}
      id="technology-modal"
      show
      on_cancel={JS.patch(~p"/technologies/#{@technology}")}
    >
      <.live_component
        module={BuiltWithPhoenixWeb.TechnologyLive.FormComponent}
        id={@technology.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        technology={@technology}
        patch={~p"/technologies/#{@technology}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :technology,
       Ash.get!(BuiltWithPhoenix.Organizations.Resource.Technology, id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Technology"
  defp page_title(:edit), do: "Edit Technology"
end
