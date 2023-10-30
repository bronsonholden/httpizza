defmodule HTTPizzaWeb.NewHTTPListenerLive do
  use HTTPizzaWeb, :live_view

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container size="sm">
      Form here
    </.container>
    """
  end
end
