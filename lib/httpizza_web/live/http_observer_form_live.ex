defmodule HTTPizzaWeb.HTTPObserverFormLive do
  @moduledoc """
  Renders a form that edits or creates an `HTTPObserver`, intended to be
  nested in another live view via `live_render/3`.

  Requires the following `session` properties:

      * `slug`: the current organization's proper slug
      * `action`: one of `:new`, `:edit`
      * `http_observer`: a new/existing `HTTPObserver` struct to create/modify

  ## Examples

      <%=
        live_render(
          @socket,
          HTTPizzaWeb.HTTPObserverFormLive,
          session: %{
            "slug" => "acme",
            "action" => :new,
            "http_observer" => %HTTPObserver{https: true, port: 443}
          }
        )
      %>
  """
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Checks
  alias HTTPizza.Observers

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(
        _params,
        %{"slug" => slug, "action" => action, "http_observer" => http_observer},
        socket
      ) do
    changeset = Observers.change_http_observer(http_observer)

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(:slug, slug)
     |> assign(:action, action)
     |> assign(:http_observer, http_observer)
     |> assign(:check_errors, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- <%= inspect(@form) %> --%>
      <.simple_form for={@form} id="http-observer-form" phx-submit="save" phx-change="validate">
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
            {"Every minute", "* * * * *"},
            {"Every hour", "0 * * * *"},
            {"Every day", "0 0 * * *"}
          ]}
        />

        <div class="flex items-center gap-4">
          <p>Header checks</p>
          <button
            type="button"
            class="rounded-full border p-1 rounded-full h-full aspect-square block flex items-center justify-center"
            phx-click="add_header_check"
          >
            <.icon name="hero-plus-mini" />
          </button>
        </div>

        <div id="http-observer-header-checks">
          <.inputs_for :let={check} field={@form[:header_checks]}>
            <fieldset class="pl-8 border-l-[4px] border-zinc-200 flex flex-col gap-2 my-4">
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

              <div>
                <button
                  class="text-zinc-500 hover:text-red-600 text-sm font-medium"
                  type="button"
                  phx-click="remove_header_check"
                  phx-value-index={check.index}
                >
                  <.icon name="hero-minus" class="scale-[60%]" /> Remove
                </button>
              </div>
            </fieldset>
          </.inputs_for>
        </div>

        <div class="flex items-center gap-4">
          <p>Status checks</p>
          <button
            type="button"
            class="rounded-full border p-1 rounded-full h-full aspect-square block flex items-center justify-center"
            phx-click="add_status_check"
          >
            <.icon name="hero-plus-mini" />
          </button>
        </div>

        <div id="http-observer-status-checks">
          <.inputs_for :let={check} field={@form[:status_checks]}>
            <fieldset class="pl-8 border-l-[4px] border-zinc-200 flex flex-col gap-2 my-4">
              <.input
                field={check[:comparator]}
                type="select"
                label="Comparator"
                phx-debounce="200"
                options={[
                  {"", ""},
                  {"Is exactly", "equal_to"},
                  {"Successful (2XX)", "is_success"},
                  {"Redirect (3XX)", "is_redirect"}
                ]}
              />
              <.input
                :if={check[:comparator].value == :equal_to}
                field={check[:code]}
                type="text"
                label="Code"
                required
                phx-debounce="200"
              />

              <div>
                <button
                  class="text-zinc-500 hover:text-red-600 text-sm font-medium"
                  type="button"
                  phx-click="remove_status_check"
                  phx-value-index={check.index}
                >
                  <.icon name="hero-minus" class="scale-[60%]" /> Remove
                </button>
              </div>
            </fieldset>
          </.inputs_for>
        </div>

        <:actions>
          <button phx-disable-with="Saving..." class="bg-orange-500 text-white rounded p-2">
            <%= if @action == :edit do %>
              Save
            <% else %>
              Create
            <% end %>
          </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("add_header_check", _params, socket) do
    existing =
      Map.get(
        socket.assigns.form.source.changes,
        :header_checks,
        socket.assigns.http_observer.header_checks
      )

    header_checks =
      existing
      |> Enum.concat([
        Checks.HeaderCheck.changeset(%Checks.HeaderCheck{}, %{})
      ])

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:header_checks, header_checks)

    form = to_form(changeset, as: "http_observer")

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("remove_header_check", %{"index" => index}, socket) do
    existing =
      Map.get(
        socket.assigns.form.source.changes,
        :header_checks,
        socket.assigns.http_observer.header_checks
      )

    {left, [_drop | right]} = Enum.split(existing, String.to_integer(index))
    updated_header_checks = Enum.concat(left, right)

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:header_checks, updated_header_checks)

    form = to_form(changeset, as: "http_observer")

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("add_status_check", _params, socket) do
    existing =
      Map.get(
        socket.assigns.form.source.changes,
        :status_checks,
        socket.assigns.http_observer.status_checks
      )

    status_checks =
      existing
      |> Enum.concat([
        Checks.StatusCheck.changeset(%Checks.StatusCheck{}, %{})
      ])

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:status_checks, status_checks)

    form = to_form(changeset, as: "http_observer")

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("remove_status_check", %{"index" => index}, socket) do
    existing =
      Map.get(
        socket.assigns.form.source.changes,
        :status_checks,
        socket.assigns.http_observer.status_checks
      )

    {left, [_drop | right]} = Enum.split(existing, String.to_integer(index))
    updated_status_checks = Enum.concat(left, right)

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:status_checks, updated_status_checks)

    form = to_form(changeset, as: "http_observer")

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event(
        "save",
        %{"http_observer" => http_observer_params},
        %{assigns: %{action: :new}} = socket
      ) do
    organization = socket.assigns.current_organization
    params = Map.put(http_observer_params, "organization_id", organization.id)

    # TODO: Check permission to create for org?
    params
    |> Observers.create_http_observer()
    |> case do
      {:ok, _observer} ->
        socket =
          socket
          |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")
          |> put_flash(:info, "HTTP observer created")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"http_observer" => http_observer_params},
        %{assigns: %{action: :edit}} = socket
      ) do
    http_observer_params =
      http_observer_params
      |> Map.update("status_checks", [], & &1)
      |> Map.update("header_checks", [], & &1)

    socket.assigns.http_observer
    |> Observers.update_http_observer(http_observer_params)
    |> case do
      {:ok, _observer} ->
        socket =
          socket
          |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")
          |> put_flash(:info, "HTTP observer updated")

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
