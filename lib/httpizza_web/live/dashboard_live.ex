defmodule HTTPizzaWeb.DashboardLive do
  alias HTTPizzaWeb.DashboardComponents
  use HTTPizzaWeb, :live_view

  alias Phoenix.LiveView.JS
  alias HTTPizza.IAM
  alias HTTPizzaWeb.ObserverComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :mount_current_organization}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, uri, %{assigns: %{current_organization: %IAM.Organization{}}} = socket) do
    http_observers =
      socket.assigns.current_organization.id
      |> HTTPizza.Observers.list_organization_http_observers()

    socket =
      socket
      |> assign(:current_uri, uri)
      |> assign(:http_observers, http_observers)

    {:noreply, socket}
  end

  def handle_params(_, _, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations_with_status_counts={
        HTTPizza.Status.get_organizations_with_status_counts(@current_user)
      }
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
      slug={@current_organization_slug}
    >
      <div class="flex items-start justify-between w-full">
        <DashboardComponents.breadcrumbs
          organization={@current_organization}
          slug={@current_organization_slug}
          title="HTTP Observers"
        />
        <.link
          class="h-full py-1 pl-1 pr-2 text-xs font-bold hover:bg-orange-400 rounded text-white bg-orange-500 flex items-center gap-1"
          navigate={~p"/dashboard/#{@current_organization_slug}/http-observers/new"}
        >
          <.icon name="hero-plus-mini" class="scale-75" /> New
        </.link>
      </div>
      <ObserverComponents.timeline_guide />
      <p
        :if={Enum.empty?(@http_observers)}
        class="font-bold text-lg text-stone-300 dark:text-stone-500 mx-auto max-w-xs text-center mt-12 mb-24"
      >
        Create an observer to get started.
      </p>
      <div
        :if={not Enum.empty?(@http_observers)}
        id="http-observers"
        class="border-collapse my-4 w-full flex flex-col gap-2"
      >
        <div
          :for={http_observer <- @http_observers}
          id={"observer-#{http_observer.id}"}
          class="open border-b border-stone-100 dark:border-stone-700 group/observer"
        >
          <div class="flex gap-2 items-center">
            <button
              type="button"
              phx-click={expand_js(http_observer.id)}
              class="rounded-full h-full flex items-center aspect-square hover:bg-stone-100 text-stone-500 hover:text-stone-800 dark:hover:bg-stone-700 dark:hover:text-stone-200"
            >
              <.icon name="hero-chevron-right" class="scale-[60%] group-[.open]/observer:hidden" />
              <.icon name="hero-chevron-down" class="scale-[60%] hidden group-[.open]/observer:block" />
            </button>

            <div class="grow flex items-start gap-2 font-mono text-sm tracking-tight font-bold">
              <p class="shrink-0 text-orange-500">
                <%= String.upcase(to_string(http_observer.method)) %>
              </p>
              <p class="text-blue-500 break-all" phx-no-format>
                <span class="text-stone-400"><%=
                  if(http_observer.https, do: "https", else: "http")
                %>://</span><%=
                  http_observer.hostname
                %><span class="text-stone-400"><%=
                  http_observer.path
                %></span>
              </p>
            </div>

            <.link
              navigate={
                ~p"/dashboard/#{@current_organization_slug}/http-observers/#{http_observer.id}/edit"
              }
              class="block hover:text-stone-800 dark:hover:text-stone-200 text-stone-400 rounded-full"
            >
              <.icon name="hero-pencil-square-mini" class="scale-[90%]" />
            </.link>
          </div>

          <div class="ml-20 hidden group-[.open]/observer:block">
            <div :for={check <- http_observer.header_checks} class="flex items-center">
              <.icon name="hero-magnifying-glass" class="text-stone-500 mr-2" />
              <ObserverComponents.check_list_item check={check} />
            </div>
            <div :for={status_check <- http_observer.status_checks} class="flex items-center">
              <.icon name="hero-magnifying-glass" class="text-stone-500 mr-2" />
              <ObserverComponents.check_list_item check={status_check} />
            </div>

            <div
              :for={{email_recipient, index} <- Enum.with_index(http_observer.email_recipients)}
              class="flex items-center gap-1 my-2"
            >
              <.icon name="hero-bell-alert" class="text-stone-500 mr-2" />
              <.dot
                :if={email_recipient.ok}
                color="bg-green-500"
                id={"#{http_observer.id}-#{index}-ok"}
              >
                Will be notified of successful observations
              </.dot>
              <.dot
                :if={email_recipient.failed}
                color="bg-red-500"
                id={"#{http_observer.id}-#{index}-failed"}
              >
                Will be notified of failed observations
              </.dot>
              <.dot
                :if={email_recipient.error}
                color="bg-stone-400"
                id={"#{http_observer.id}-#{index}-error"}
              >
                Will be notified of errors
              </.dot>
              <p class="font-mono text-xs"><%= email_recipient.email %></p>
            </div>
          </div>

          <p class="text-right text-xs text-stone-600 dark:text-stone-400 mt-2">
            Next run <%= Timex.format!(http_observer.scheduled_at, "{relative}", :relative) %>
          </p>

          <div class="py-2">
            <ObserverComponents.status_bar
              slug={@current_organization_slug}
              http_observations={http_observer.http_observations}
            />
          </div>
        </div>
      </div>
    </.dashboard>
    """
  end

  attr(:id, :string, required: true)
  attr(:color, :string, required: true)
  slot(:inner_block, required: true)

  defp dot(assigns) do
    ~H"""
    <.tooltip id={@id}>
      <:trigger><div class={"w-2 h-2 rounded-full #{@color}"} /></:trigger>
      <p class="whitespace-nowrap"><%= render_slot(@inner_block) %></p>
    </.tooltip>
    """
  end

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)

  defp info_label(assigns) do
    ~H"""
    <p class="px-1 border bg-stone-100 rounded shrink-0 whitespace-nowrap">
      <span class="text-orange-500"><%= @label %>:</span>
      <span class="text-stone-400 font-bold">
        <%= @value %>
      </span>
    </p>
    """
  end

  defp expand_js(id) do
    %JS{}
    |> JS.add_class("open", to: "[id='observer-#{id}']:not(.open)")
    |> JS.remove_class("open", to: "[id='observer-#{id}'].open")
  end
end
