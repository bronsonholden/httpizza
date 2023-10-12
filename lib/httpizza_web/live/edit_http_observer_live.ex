defmodule HTTPizzaWeb.EditHTTPObserverLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # TODO: verify in org
    http_observer = Observers.get_http_observer!(id)

    {:ok, assign(socket, :http_observer, http_observer)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container size="sm">
      <%= live_render(@socket, HTTPizzaWeb.HTTPObserverFormLive,
        id: "new-http-observer-form",
        session: %{
          "slug" => @current_organization_slug,
          "action" => :edit,
          "http_observer" => @http_observer
        }
      ) %>
    </.container>
    """
  end
end
