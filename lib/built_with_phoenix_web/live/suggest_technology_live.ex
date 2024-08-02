defmodule BuiltWithPhoenixWeb.SuggestTechnologyLive do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Technology

  alias Phoenix.LiveView

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-8 mt-12">
      <div class="grid content-start gap-10">
        <.text_header>
          Suggest a Technology
        </.text_header>
        <.p>
          Missing a technology in the list, suggest one!
        </.p>

        <.form
          for={@form}
          id="technology-form"
          phx-change="validate"
          phx-submit="save"
          class="min-w-0 max-h-min grid gap-y-8"
        >
          <.section title="Tell us about the Organization">
            <.input field={@form[:name]} label="Organization name" required placeholder="The Mykolas" />
            <.input
              field={@form[:url]}
              label="Organization url"
              required
              placeholder="https://themykolas.com"
            />
            <.logo_input id="logo" value={@form[:logo].value} upload={@uploads.logo} />
            <.input
              type="textarea"
              field={@form[:description]}
              label="Description"
              placeholder="A short description of what the organization does"
            />
          </.section>
          <.button type="submit" phx-disable-with="Saving...">Suggest Technology</.button>
        </.form>
      </div>
    </div>
    """
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_form()
     |> allow_upload(:logo,
       accept: ["image/*"],
       auto_upload: true,
       max_entries: 1,
       external: &presign_upload/2
     )}
  end

  @impl LiveView
  def handle_event("cancel-upload", %{"key" => key, "ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, String.to_existing_atom(key), ref)}
  end

  def handle_event("validate", %{"technology" => technology_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, technology_params))}
  end

  def handle_event("save", %{"technology" => technology_params}, socket) do
    technology_params =
      technology_params
      |> Map.put("logo", get_file(socket, :logo))

    case AshPhoenix.Form.submit(socket.assigns.form, params: technology_params) do
      {:ok, technology} ->
        socket =
          socket
          |> put_flash(:info, "Technology #{technology.name} successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_create(Technology, :create, as: "technology")

    assign(socket, form: to_form(form))
  end

  defp presign_upload(entry, %{assigns: %{uploads: uploads}} = socket) do
    meta = S3Uploader.meta(entry, uploads)

    {:ok, meta, socket}
  end

  defp get_file(socket, upload_key) do
    consume_uploaded_entries(socket, upload_key, fn _, entry ->
      {:ok, S3Uploader.entry_url(entry)}
    end)
    |> List.first()
  end
end
