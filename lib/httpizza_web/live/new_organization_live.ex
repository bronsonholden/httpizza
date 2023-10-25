defmodule HTTPizzaWeb.NewOrganizationLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      IAM.change_organization(%IAM.Organization{}, %{
        slug: HTTPizzaWeb.Slug.generate()
      })

    socket =
      socket
      |> assign(:form, to_form(changeset, as: "organization"))
      |> assign(:check_errors, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container>
      <.simple_form for={@form} id="new-organization-form" phx-submit="create" phx-change="validate">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@form[:name]}
          type="text"
          label="Organization name"
          required
          phx-debounce="200"
        />
        <.input
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          spellcheck="false"
          field={@form[:slug]}
          type="text"
          label="Slug"
          required
          phx-debounce="200"
        />

        <:actions>
          <.button phx-disable-with="Creating organization..." class="w-full">
            Create organization
          </.button>
        </:actions>
      </.simple_form>
    </.container>
    """
  end

  @impl true
  def handle_event("create", %{"organization" => organization_params}, socket) do
    organization_params
    |> Map.put("users", [socket.assigns.current_user])
    |> IAM.create_organization()
    |> case do
      {:ok, organization} ->
        Oban.insert(
          HTTPizza.CreateStripeCustomerWorker.new(%{
            "id" => organization.id,
            "email" => socket.assigns.current_user.email,
            "name" => organization.name
          })
        )

        {:noreply, push_navigate(socket, to: ~p"/dashboard/#{organization.slug}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"organization" => organization_params}, socket) do
    changeset =
      %IAM.Organization{}
      |> IAM.change_organization(organization_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "organization")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
