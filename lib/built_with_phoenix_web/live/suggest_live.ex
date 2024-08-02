defmodule BuiltWithPhoenixWeb.SuggestLive do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  alias Phoenix.LiveView

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-8 mt-12 grid gap-12 md:grid-cols-[1fr_1px_256px]">
      <div class="grid gap-10">
        <.text_header>
          Suggest an organization
        </.text_header>

        <.form
          for={@form}
          id="organization-form"
          phx-change="validate"
          phx-submit="save"
          class="min-w-0 grid gap-y-8"
        >
          <.section title="Tell us about the Organization">
            <.input field={@form[:name]} label="Organization name" required placeholder="The Mykolas" />
            <.input
              field={@form[:url]}
              label="Organization url"
              required
              placeholder="https://themykolas.com"
            />

            <.logo_input id="logo" upload={@uploads.logo} />
            <.image_input id="image" upload={@uploads.image} />
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
            <.input type="checkgroup" field={@form[:technologies]} options={@technologies} />
          </.section>
          <.section title="Tell us about yourself">
            <.input field={@form[:author_name]} label="Your name" placeholder="Firstname Lastname" />
            <.input field={@form[:author_email]} label="Your email" placeholder="you@awesome.com" />
          </.section>
          <.button type="submit" phx-disable-with="Saving...">Suggest Organization</.button>
        </.form>
      </div>

      <div class="h-full border-t border-zinc-400 md:border-l"></div>

      <.what_belongs_here />
    </div>
    """
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
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

  @impl LiveView
  def handle_event("cancel-upload", %{"key" => key, "ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, String.to_existing_atom(key), ref)}
  end

  def handle_event("validate", %{"organization" => organization_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, organization_params))}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    organization_params =
      organization_params
      |> Map.put("logo", get_file(socket, :logo))
      |> Map.put("image", get_file(socket, :image))

    case AshPhoenix.Form.submit(socket.assigns.form, params: organization_params) do
      {:ok, organization} ->
        socket =
          socket
          |> put_flash(:info, "Organization #{organization.name} successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_create(Organization, :create_suggestion, as: "organization")

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

  attr :upload, :map, required: true
  attr :id, :string, required: true

  defp image_input(assigns) do
    ~H"""
    <div class="col-span-full">
      <.live_file_input upload={@upload} class="sr-only" />
      <.label for={@upload.ref}>
        Cover photo
      </.label>
      <div
        :if={@upload.entries == []}
        phx-drop-target={@upload.ref}
        class="border-zinc-900/25 aspect-video mt-2 flex items-center justify-center rounded-lg border border-dashed px-6 py-10"
      >
        <div class="text-center">
          <svg
            class="mx-auto h-12 w-12 text-gray-300"
            viewBox="0 0 24 24"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M1.5 6a2.25 2.25 0 012.25-2.25h16.5A2.25 2.25 0 0122.5 6v12a2.25 2.25 0 01-2.25 2.25H3.75A2.25 2.25 0 011.5 18V6zM3 16.06V18c0 .414.336.75.75.75h16.5A.75.75 0 0021 18v-1.94l-2.69-2.689a1.5 1.5 0 00-2.12 0l-.88.879.97.97a.75.75 0 11-1.06 1.06l-5.16-5.159a1.5 1.5 0 00-2.12 0L3 16.061zm10.125-7.81a1.125 1.125 0 112.25 0 1.125 1.125 0 01-2.25 0z"
              clip-rule="evenodd"
            />
          </svg>
          <div class="mt-4 flex text-sm leading-6 text-gray-600">
            <label
              for={@upload.ref}
              class="relative cursor-pointer rounded-md bg-white font-semibold text-indigo-600 focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-600 focus-within:ring-offset-2 hover:text-indigo-500"
            >
              <span>Upload a file</span>
            </label>
            <p class="pl-1">or drag and drop</p>
          </div>
          <p class="text-xs leading-5 text-gray-600">PNG, JPG, GIF up to 8MB</p>
          <p class="text-xs leading-5 text-gray-600">Resolution 1920x1080</p>
        </div>
      </div>

      <div
        :if={@upload.entries != []}
        phx-drop-target={@upload.ref}
        class="aspect-video relative mt-2 flex items-center justify-center border border-black"
      >
        <.live_img_preview :for={entry <- @upload.entries} entry={entry} class="w-full h-auto" />

        <div class="absolute right-4 bottom-4 flex items-center justify-end gap-4">
          <button
            :for={entry <- @upload.entries}
            type="button"
            class="block rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-red-600 shadow-sm ring-1 ring-inset ring-red-300 hover:bg-red-50"
            phx-click="cancel-upload"
            phx-value-key={@id}
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            Remove
          </button>

          <label
            for={@upload.ref}
            class="block rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-zinc-800 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            Change
          </label>
        </div>
      </div>

      <.upload_errors_list upload={@upload} />
    </div>
    """
  end

  defp what_belongs_here(assigns) do
    ~H"""
    <aside>
      <.text_header>
        What belongs here?
      </.text_header>
      <ul class="mt-10 grid gap-6">
        <li>
          <.p>
            Companies and non-profits using Phoenix to do or support the work of their organization (whether that's "make profit" or "teach healthcare" or whatever else)
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            No packages or other code
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            No individual courses or books or other training resources
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            If it's a developer-focused SaaS, it needs to be large--think Fathom Analytics, not someone's passion side project
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            We have a bias against tools that are only targeted at Phoenix developers, because those tools won't add any impact to folks' understanding how Phoenix is used in the broader world
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            Agencies are only allowed if they also have products, and are here to show their products
          </.p>
        </li>
        <hr class="border-zinc-400" />
        <li>
          <.p>
            Marketing sites for individual developers or agencies aren't allowed as sites examples
          </.p>
        </li>
      </ul>
    </aside>
    """
  end
end
