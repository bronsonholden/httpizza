defmodule HTTPizzaWeb.OrganizationLive do
  use HTTPizzaWeb, :live_view

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_uri, uri)}
  end

  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations={@current_user.organizations}
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
    >
      <h1 class="text-2xl font-bold">Organization settings</h1>
    </.dashboard>
    """
  end
end
