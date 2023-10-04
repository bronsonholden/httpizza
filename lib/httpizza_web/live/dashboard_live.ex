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
  def handle_params(_, _, %{assigns: %{current_organization: %IAM.Organization{}}} = socket) do
    {:noreply, socket}
  end

  def handle_params(_, _, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}

  @impl true
  def render(assigns) do
    ~H"""
    <.container>
      <div class="flex flex-col gap-4">
        <DashboardComponents.organization_select
          id="organization-select"
          selection={@current_organization}
          organizations={@current_user.organizations}
          personal_organization_id={@current_user.personal_organization.id}
        />
      </div>
    </.container>
    """
  end
end
