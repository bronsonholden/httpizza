defmodule HTTPizzaWeb.DashboardLive do
  alias HTTPizzaWeb.DashboardComponents
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => "personal"}, _uri, socket) do
    org = socket.assigns.current_user.personal_organization

    {:noreply, assign(socket, :organization, org)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    org = IAM.get_user_organization_by_slug(socket.assigns.current_user, slug)

    if org do
      {:noreply, assign(socket, :organization, org)}
    else
      {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container>
      <div class="flex flex-col gap-4">
        <DashboardComponents.organization_select
          id="organization-select"
          selection={@organization}
          organizations={@current_user.organizations}
          personal_organization_id={@current_user.personal_organization.id}
        />
      </div>
    </.container>
    """
  end
end
