defmodule BuiltWithPhoenixWeb.TechnologyLive.FormComponent do
  use BuiltWithPhoenixWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage technology records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="technology-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" /><.input
          field={@form[:url]}
          type="text"
          label="Url"
        /><.input field={@form[:image_url]} type="text" label="Image url" />

        <.button phx-disable-with="Saving...">Save Technology</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"technology" => technology_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, technology_params))}
  end

  def handle_event("save", %{"technology" => technology_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: technology_params) do
      {:ok, technology} ->
        notify_parent({:saved, technology})

        socket =
          socket
          |> put_flash(:info, "Technology #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{technology: technology}} = socket) do
    form =
      if technology do
        AshPhoenix.Form.for_update(technology, :update,
          as: "technology",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(BuiltWithPhoenix.Organizations.Resource.Technology, :create,
          as: "technology",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
