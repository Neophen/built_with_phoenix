defmodule BuiltWithPhoenixWeb.Admin.OrganizationLive.FormComponent do
  use BuiltWithPhoenixWeb, :live_component

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.Technology
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="organization-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="grid min-w-0 gap-y-8"
      >
        <.section title="Tell us about the Organization">
          <.input field={@form[:name]} label="Organization name" required placeholder="The Mykolas" />
          <.input field={@form[:weight]} label="Weight" />
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

          <.image_input id="image" upload={@uploads.image} value={@form[:image].value} />
        </.section>

        <.section title="How do you know they use Phoenix Framework?">
          <div class="grid-fit-cols-[256px] grid gap-4">
            <.input
              type="textarea"
              field={@form[:usage_public]}
              label="Public"
              placeholder="This information will be shared publicly"
            />
            <%!-- errors={["if this information can safely be shared publicly"]} --%>
            <.input
              type="textarea"
              field={@form[:usage_private]}
              label="Private"
              placeholder="This information will not be shared publicly"
            />
            <%!-- description="if this information cannot safely be shared publicly" --%>
          </div>
        </.section>
        <.section title="What sites/microsites/apps specifically use Phoenix? (new line for each URL)">
          <.input
            type="textarea"
            field={@form[:extra_sites]}
            label="Sites"
            placeholder="https://themykolas.com"
          />
        </.section>

        <.section title="What technologies are they using?">
          <.input
            type="checkgroup"
            field={@form[:technologies]}
            value={get_checkgroup_value(@form[:technologies].value)}
            options={@technologies}
          />
        </.section>
        <.section title="Tell us about yourself">
          <.input field={@form[:author_name]} label="Your name" placeholder="Firstname Lastname" />
          <.input field={@form[:author_email]} label="Your email" placeholder="you@awesome.com" />
        </.section>
        <.button type="submit" phx-disable-with="Saving...">Save Organization</.button>
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
     )
     |> allow_upload(:image,
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

  def handle_event("validate", %{"organization" => organization_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, organization_params))}
  end

  def handle_event(
        "save",
        %{"organization" => organization_params},
        %{assigns: %{organization: organization}} = socket
      ) do
    organization_params =
      organization_params
      |> Map.put("logo", get_file(socket, :logo, organization.logo))
      |> Map.put("image", get_file(socket, :image, organization.image))

    case AshPhoenix.Form.submit(socket.assigns.form, params: organization_params) do
      {:ok, organization} ->
        notify_parent({:saved, organization})

        socket =
          socket
          |> put_flash(:info, "Organization #{socket.assigns.form.source.type}d successfully")
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

  defp assign_form(%{assigns: %{organization: organization}} = socket) do
    form =
      if organization do
        AshPhoenix.Form.for_update(organization, :update,
          as: "organization",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Organization, :create,
          as: "organization",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
