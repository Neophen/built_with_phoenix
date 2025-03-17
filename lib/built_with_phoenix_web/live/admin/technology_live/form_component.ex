defmodule BuiltWithPhoenixWeb.Admin.TechnologyLive.FormComponent do
  use BuiltWithPhoenixWeb, :live_component

  alias BuiltWithPhoenix.Organizations.Resource.Technology
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="technology-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="grid min-w-0 gap-y-8"
      >
        <.section title="Tell us about the Technology">
          <.input field={@form[:name]} label="Technology name" required placeholder="The Mykolas" />
          <.input
            field={@form[:url]}
            label="Technology url"
            required
            placeholder="https://themykolas.com"
          />

          <.logo_input id="logo" value={@form[:logo].value} upload={@uploads.logo} />
          <.input
            type="textarea"
            field={@form[:description]}
            label="Description"
            placeholder="A short description of what the technology does"
          />
        </.section>
        <.button type="submit" phx-disable-with="Saving...">Save Technology</.button>
      </.form>
    </div>
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()
     |> assign(
       :technologies,
       Ash.read!(Technology) |> Enum.map(fn tech -> {tech.name, tech.id} end)
     )
     |> allow_upload(:logo,
       accept: ["image/*"],
       auto_upload: true,
       max_entries: 1,
       external: &presign_upload/2
     )}
  end

  @impl LiveComponent
  def handle_event("cancel-upload", %{"key" => key, "ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, String.to_existing_atom(key), ref)}
  end

  def handle_event("validate", %{"technology" => technology_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, technology_params))}
  end

  def handle_event(
        "save",
        %{"technology" => technology_params},
        %{assigns: %{technology: technology}} = socket
      ) do
    technology_params =
      technology_params
      |> Map.put("logo", get_file(socket, :logo, technology.logo))

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

  defp presign_upload(entry, %{assigns: %{uploads: uploads}} = socket) do
    meta = S3Uploader.meta(entry, uploads)
    {:ok, meta, socket}
  end

  defp get_file(socket, upload_key, default) do
    consume_uploaded_entries(socket, upload_key, fn _, entry ->
      {:ok, S3Uploader.entry_url(entry)}
    end)
    |> List.first()
    |> get_file_value(default)
  end

  defp get_file_value(nil, default), do: default
  defp get_file_value(new_value, _default), do: new_value

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{technology: technology}} = socket) do
    form =
      if technology do
        AshPhoenix.Form.for_update(technology, :update,
          as: "technology",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Technology, :create,
          as: "technology",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
