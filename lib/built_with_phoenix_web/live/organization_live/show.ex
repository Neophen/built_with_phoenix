defmodule BuiltWithPhoenixWeb.OrganizationLive.Show do
  use BuiltWithPhoenixWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid gap-8 p-8">
      <.header>
        Organization <%= @organization.id %>
        <:subtitle>This is a organization record from your database.</:subtitle>

        <:actions>
          <.link patch={~p"/organizations/#{@organization}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit organization</.button>
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Id"><%= @organization.id %></:item>

        <:item title="Name"><%= @organization.name %></:item>

        <:item title="Url"><%= @organization.url %></:item>

        <:item title="Logo"><%= @organization.logo %></:item>

        <:item title="Image"><%= @organization.image %></:item>

        <:item title="Usage public"><%= @organization.usage_public %></:item>

        <:item title="Usage private"><%= @organization.usage_private %></:item>

        <:item title="Extra sites"><%= @organization.extra_sites %></:item>

        <:item title="Author name"><%= @organization.author_name %></:item>

        <:item title="Author email"><%= @organization.author_email %></:item>
      </.list>

      <.back navigate={~p"/organizations"}>Back to organizations</.back>
    </div>
    <.modal
      :if={@live_action == :edit}
      id="organization-modal"
      on_cancel={JS.patch(~p"/organizations/#{@organization}")}
    >
      <.live_component
        module={BuiltWithPhoenixWeb.OrganizationLive.FormComponent}
        id={@organization.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        organization={@organization}
        patch={~p"/organizations/#{@organization}"}
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
       :organization,
       Ash.get!(BuiltWithPhoenix.Organizations.Resource.Organization, id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
end
