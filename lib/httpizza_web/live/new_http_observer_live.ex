defmodule HTTPizzaWeb.NewHTTPObserverLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Checks.HeaderCheck
  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      %Observers.HTTPObserver{}
      |> Observers.change_http_observer(%{
        hostname: "",
        header_checks: [%{}],
        port: 80
      })

    socket =
      socket
      |> assign(:form, to_form(changeset, as: "http_observer"))
      |> assign(:changeset, changeset)
      |> assign(:check_errors, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container size="sm">
      <.simple_form for={@form} id="new-http-observer-form" phx-submit="create" phx-change="validate">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:https]} type="checkbox" label="HTTPS" phx-debounce="200" />
        <.input field={@form[:hostname]} type="text" label="Hostname" required phx-debounce="200" />
        <.input field={@form[:path]} type="text" label="Path" phx-debounce="200" />
        <.input field={@form[:port]} type="text" label="Port" required phx-debounce="200" />

        <.input
          field={@form[:method]}
          type="select"
          label="Method"
          required
          phx-debounce="200"
          options={[
            {"GET", "get"}
          ]}
        />

        <.input
          field={@form[:schedule]}
          type="select"
          required
          label="Schedule"
          phx-debounce="200"
          options={[
            {"Every minute", "0 * * * *"},
            {"Every hour", "0 0 * * *"},
            {"Every day", "0 0 0 * *"}
          ]}
        />

        <div class="flex items-center gap-4">
          <p>Head checks</p>
          <button
            type="button"
            class="rounded-full border p-1 rounded-full h-full aspect-square block flex items-center justify-center"
            phx-click="add_header_check"
          >
            <.icon name="hero-plus-mini" />
          </button>
        </div>

        <div id="new-http-observer-header-checks">
          <.inputs_for :let={check} field={@form[:header_checks]}>
            <fieldset class="pl-8 border-l-[4px] border-zinc-200 flex flex-col gap-2">
              <.input field={check[:header]} type="text" label="Header" required phx-debounce="200" />
              <.input
                field={check[:comparator]}
                type="select"
                required
                label="Comparator"
                phx-debounce="200"
                options={[
                  {"Is exactly", "equal_to"},
                  {"Contains", "contains"},
                  {"Starts with", "starts_with"},
                  {"Ends with", "ends_with"},
                  {"Doesn't contain", "does_not_contain"},
                  {"Is not exactly", "not_equal_to"}
                ]}
              />
              <.input field={check[:value]} type="text" label="Value" required phx-debounce="200" />
              <.input field={check[:case_sensitive]} type="checkbox" label="Case sensitive" />
            </fieldset>
          </.inputs_for>
        </div>

        <:actions>
          <.button phx-disable-with="Creating HTTP observer..." class="w-full">
            Create HTTP observer
          </.button>
        </:actions>
      </.simple_form>
    </.container>
    """
  end

  @impl true
  def handle_event("add_header_check", _params, socket) do
    # TODO: when editing observer
    # default value for Map.get/3 `socket.assigns.http_observer.header_checks`
    existing = Map.get(socket.assigns.changeset.changes, :header_checks, [])

    header_checks =
      existing
      |> Enum.concat([
        HeaderCheck.changeset(%HeaderCheck{}, %{})
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:header_checks, header_checks)

    form = to_form(changeset, as: "http_observer")

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("create", %{"http_observer" => http_observer_params}, socket) do
    organization = socket.assigns.current_organization
    params = Map.put(http_observer_params, "organization_id", organization.id)

    # TODO: Check permission to create for org?
    params
    |> Observers.create_http_observer()
    |> case do
      {:ok, _observer} ->
        socket =
          socket
          |> push_navigate(
            to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/observers"
          )
          |> put_flash(:info, "HTTP observer created")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"http_observer" => http_observer_params}, socket) do
    changeset =
      %Observers.HTTPObserver{}
      |> Observers.change_http_observer(http_observer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "http_observer")

    if changeset.valid? do
      assign(socket, form: form, changeset: changeset, check_errors: false)
    else
      assign(socket, form: form, changeset: changeset)
    end
  end
end
