defmodule BuiltWithPhoenixWeb.SuggestLive do
  use BuiltWithPhoenixWeb, :live_view

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  alias BuiltWithPhoenixWeb.Fetcher

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
            <.input
              field={@form[:url]}
              label="Organization url"
              required
              placeholder="https://themykolas.com"
              phx-debounce="200"
            />
            <.input
              field={@form[:name]}
              label="Organization name"
              required
              placeholder="The Mykolas"
              phx-debounce="500"
            />
            <.input
              type="textarea"
              field={@form[:description]}
              label="Description"
              placeholder="A short description of what the organization does"
              phx-debounce="500"
            />
            <.logo_input id="logo" value={@form[:logo].value} upload={@uploads.logo} />
            <.input type="hidden" field={@form[:logo]} />

            <.image_input id="image" upload={@uploads.image} value={@form[:image].value} />
            <.input type="hidden" field={@form[:image]} />
          </.section>

          <.section title="How do you know they use Phoenix Framework?">
            <div class="grid-fit-cols-[256px] grid gap-4">
              <.input
                type="textarea"
                field={@form[:usage_public]}
                label="Public"
                placeholder="This information will be shared publicly"
                phx-debounce="500"
              />
              <%!-- errors={["if this information can safely be shared publicly"]} --%>
              <.input
                type="textarea"
                field={@form[:usage_private]}
                label="Private"
                placeholder="This information will not be shared publicly"
                phx-debounce="500"
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
              phx-debounce="500"
            />
          </.section>

          <.section title="What technologies are they using?">
            <.input type="checkgroup" field={@form[:technologies]} options={@technologies} />
          </.section>
          <.section title="Tell us about yourself">
            <.input
              field={@form[:author_name]}
              label="Your name"
              placeholder="Firstname Lastname"
              phx-debounce="500"
            />
            <.input
              field={@form[:author_email]}
              label="Your email"
              placeholder="you@awesome.com"
              phx-debounce="500"
            />
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

  def handle_event(
        "validate",
        %{"_target" => ["organization", "url"], "organization" => organization_params},
        socket
      ) do
    site_params = Fetcher.fetch_website_details(organization_params["url"])
    organization_params = Map.merge(organization_params, site_params)

    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, organization_params))}
  end

  def handle_event("validate", %{"organization" => organization_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, organization_params))}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    organization_params =
      organization_params
      |> add_file("logo", socket)
      |> add_file("image", socket)
      |> dbg()

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
      AshPhoenix.Form.for_create(Organization, :create, as: "organization")

    assign(socket, form: to_form(form))
  end

  defp presign_upload(entry, %{assigns: %{uploads: uploads}} = socket) do
    meta = S3Uploader.meta(entry, uploads)
    {:ok, meta, socket}
  end

  defp add_file(params, key, socket) do
    if params[key] == "" do
      upload_key = String.to_existing_atom(key)

      value =
        consume_uploaded_entries(socket, upload_key, fn _, entry ->
          {:ok, S3Uploader.entry_url(entry)}
        end)
        |> List.first()

      Map.put(params, key, value)
    else
      params
    end
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
