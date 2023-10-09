defmodule HTTPizzaWeb.ObserversLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizzaWeb.ObserverComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  def mount(_params, _session, socket) do
    http_observers =
      socket.assigns.current_organization.id
      |> HTTPizza.Observers.list_organization_http_observers()

    {:ok, assign(socket, :http_observers, http_observers)}
  end

  def handle_params(_, uri, socket), do: {:noreply, assign(socket, :current_uri, uri)}

  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      current_organization={@current_organization}
      personal_organization={@current_user.personal_organization}
      organizations={@current_user.organizations}
      slug={@current_organization_slug}
    >
      <div class="flex items-center justify-between w-full">
        <h1 class="text-2xl font-bold">
          HTTP Observers
        </h1>
        <.link
          class="h-full py-1 pl-1 pr-2 text-sm font-bold hover:bg-orange-600 rounded-lg text-white bg-orange-500 flex items-center gap-1"
          navigate={~p"/dashboard/#{@current_organization_slug}/http-observers/new"}
        >
          <.icon name="hero-plus-mini" /> New
        </.link>
      </div>
      <ObserverComponents.timeline_guide />
      <div id="http-observers" class="border-collapse my-4 w-full flex flex-col gap-2">
        <div :for={{http_observer, index} <- Enum.with_index(@http_observers)} class="border-b">
          <div class="flex gap-2 items-center">
            <div class="text-xs text-zinc-400 pr-1">
              <%= index + 1 %>
            </div>

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
end
