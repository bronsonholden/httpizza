defmodule HTTPizzaWeb.NewHTTPObserverLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    with :ok <-
           HTTPizza.HTTPObserverPolicy.authorize(
             "create",
             socket.assigns.current_user,
             socket.assigns.current_organization
           ) do
      {:ok, socket}
    else
      {:unauthorized, reason} ->
        socket =
          socket
          |> put_flash(:error, reason)
          |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container size="sm">
      <%= live_render(@socket, HTTPizzaWeb.HTTPObserverFormLive,
        id: "new-http-observer-form",
        session: %{
          "slug" => @current_organization_slug,
          "action" => :new,
          "http_observer" => %Observers.HTTPObserver{port: 80, method: :get, schedule: "0 * * * *"}
        }
      ) %>
    </.container>
    """
  end
end
