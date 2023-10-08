defmodule HTTPizzaWeb.ObserversLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers.HTTPObserver

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
          class="p-3 hover:bg-zinc-100"
          navigate={~p"/dashboard/#{@current_organization_slug}/http-observers/new"}
        >
          New
        </.link>
      </div>
      <.table id="http-observers" rows={@http_observers}>
        <:col :let={http_observer} label="Endpoint">
          <%= display_endpoint(http_observer) %>
        </:col>
        <:action :let={_http_observer}>
          <p data-todo>Edit</p>
          <p data-todo>Delete</p>
        </:action>
      </.table>
    </.dashboard>
    """
  end

  defp display_endpoint(%HTTPObserver{} = http_observer) do
    URI.to_string(%URI{
      host: http_observer.hostname,
      port: http_observer.port,
      path: http_observer.path,
      scheme: if(http_observer.https, do: "https", else: "http")
    })
  end
end
