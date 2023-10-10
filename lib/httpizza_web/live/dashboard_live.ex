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
      organizations={@current_user.organizations}
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
          class="h-full py-1 pl-1 pr-2 text-sm font-bold hover:bg-orange-600 rounded-lg text-white bg-orange-500 flex items-center gap-1"
          navigate={~p"/dashboard/#{@current_organization_slug}/http-observers/new"}
        >
          <.icon name="hero-plus-mini" /> New
        </.link>
      </div>
      <ObserverComponents.timeline_guide />
      <div id="http-observers" class="border-collapse my-4 w-full flex flex-col gap-2">
        <div
          :for={{http_observer, index} <- Enum.with_index(@http_observers)}
          id={"observer-#{http_observer.id}"}
          class="open border-b group/observer"
        >
          <div class="flex gap-2 items-center">
            <div class="text-xs text-zinc-400 pr-1">
              <%= index + 1 %>
            </div>

            <button
              type="button"
              phx-click={expand_js(http_observer.id)}
              class="rounded-full h-full flex items-center aspect-square hover:bg-zinc-100 hover:text-zinc-800"
            >
              <.icon
                name="hero-chevron-right"
                class="text-zinc-500 scale-[60%] group-[.open]/observer:hidden"
              />
              <.icon
                name="hero-chevron-down"
                class="text-zinc-500 scale-[60%] hidden group-[.open]/observer:block"
              />
            </button>

            <div class="grow font-mono">
              <p class="tracking-tight text-blue-500 text-sm font-bold break-all" phx-no-format>
                <span class="text-orange-500">
                  <%= String.upcase(to_string(http_observer.method)) %>
                </span>
                <span class="text-zinc-400"><%=
                  if(http_observer.https, do: "https", else: "http")
                %>://</span><%=
                  http_observer.hostname
                %><span class="text-zinc-400"><%=
                  http_observer.path
                %></span>
              </p>
            </div>

            <.link
              navigate={
                ~p"/dashboard/#{@current_organization_slug}/http-observers/#{http_observer.id}"
              }
              class="block hover:text-zinc-800 text-zinc-400 rounded-full"
            >
              <.icon name="hero-pencil-square-mini" class="scale-[90%]" />
            </.link>
          </div>

          <div class="ml-20 hidden group-[.open]/observer:block">
            <div :for={check <- http_observer.header_checks} class="flex items-center">
              <ObserverComponents.check_list_icon />
              <ObserverComponents.check_list_item check={check} />
            </div>
          </div>

          <div class="py-2">
            <ObserverComponents.status_bar http_observations={http_observer.http_observations} />
          </div>
        </div>
      </div>
    </.dashboard>
    """
  end

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)

  defp info_label(assigns) do
    ~H"""
    <p class="px-1 border bg-zinc-100 rounded shrink-0 whitespace-nowrap">
      <span class="text-orange-500"><%= @label %>:</span>
      <span class="text-zinc-400 font-bold">
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
