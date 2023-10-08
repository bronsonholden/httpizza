defmodule HTTPizzaWeb.DashboardLive do
  alias HTTPizzaWeb.DashboardComponents
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :mount_current_organization}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, uri, %{assigns: %{current_organization: %IAM.Organization{}}} = socket) do
    socket = assign(socket, :current_uri, uri)
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
    >
    </.dashboard>
    """
  end
end
