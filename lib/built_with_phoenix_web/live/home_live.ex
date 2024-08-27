defmodule BuiltWithPhoenixWeb.HomeLive do
  use BuiltWithPhoenixWeb, :live_view

  require Ash.Query

  alias BuiltWithPhoenix.Organizations.Resource.Organization
  alias BuiltWithPhoenix.Organizations.Resource.Technology

  alias Phoenix.LiveView

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="mt-12">
      <div class=""></div>

      <.form
        for={@form}
        id="technologies-form"
        phx-change="change-technologies"
        class="min-w-0 mx-auto w-max max-w-full"
      >
        <.input type="checkgroup" field={@form[:technologies]} options={@technologies} />
      </.form>

      <ul class="grid-fill-cols-[256px] mt-6 grid gap-4">
        <li :for={organization <- @organizations} key={organization.id}>
          <.organization_card
            id={organization.id}
            name={organization.name}
            logo={organization.logo}
            image={organization.image}
          />
        </li>
      </ul>
      <.footer user?={not is_nil(@current_user)} />
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
       Technology
       |> Ash.Query.for_read(:available)
       |> Ash.Query.sort(:name)
       |> Ash.read!()
       |> Enum.map(fn tech -> {tech.name, tech.id} end)
     )
     |> assign(:current_user, Map.get(socket.assigns, :current_user))
     |> assign_organizations()}
  end

  @impl LiveView
  def handle_event("change-technologies", %{"organization" => params}, socket) do
    {:noreply,
     socket
     |> assign(
       :form,
       AshPhoenix.Form.validate(socket.assigns.form, params) |> Map.put(:errors, [])
     )
     |> assign_organizations()}
  end

  defp assign_organizations(%{assigns: %{form: form}} = socket) do
    assign(socket, :organizations, active(Map.get(form.params, "technologies")))
  end

  defp assign_form(socket) do
    form = AshPhoenix.Form.for_create(Organization, :create, as: "organization")

    assign(socket, form: to_form(form))
  end

  def active(nil), do: Organization.active!()
  def active(""), do: Organization.active!()

  def active(technologies),
    do:
      Organization
      |> Ash.Query.for_read(:active)
      |> Ash.Query.filter(technologies.id in ^technologies)
      |> Ash.read!()
end
