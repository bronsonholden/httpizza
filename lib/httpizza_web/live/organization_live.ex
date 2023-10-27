defmodule HTTPizzaWeb.OrganizationLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM.{Organization, User}
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_uri, uri)}
  end

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations_with_status_counts={
        HTTPizza.Status.get_organizations_with_status_counts(@current_user)
      }
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
      slug={@current_organization_slug}
      path="/settings"
    >
      <DashboardComponents.breadcrumbs
        organization={@current_organization}
        slug={@current_organization_slug}
        title="Settings"
      />

      <p class="text-2xl font-bold my-8"><%= @current_organization.name %> organization</p>

      <div class="border rounded-lg border-red-300 bg-red-300/20 p-4 space-y-4 my-12">
        <p class="font-bold text-red-500">Danger Zone</p>
        <div class="flex flex-col items-start sm:flex-row sm:items-center gap-4 text-sm w-full">
          <p class="grow text-red-500">Deletes the organization, all observers, and all data.</p>

          <.danger_button
            organization={@current_organization}
            current_user={@current_user}
            on_click={show_modal("delete-organization-confirm")}
            label="Delete Organization"
            reason="Can't delete your personal organization"
          />
        </div>

        <div class="flex flex-col items-start sm:flex-row sm:items-center gap-4 text-sm w-full">
          <p class="grow text-red-500">Leave the organization.</p>

          <.danger_button
            organization={@current_organization}
            current_user={@current_user}
            on_click={show_modal("leave-organization-confirm")}
            label="Leave Organization"
            reason="Can't leave your personal organization"
          />
        </div>
      </div>
    </.dashboard>

    <.modal id="delete-organization-confirm">
      <div class="space-y-4">
        <p>
          Really delete <%= @current_organization.name %>? This is <span class="font-bold text-red-500">irreversible</span>.
        </p>
        <button
          phx-click="delete_organization"
          class="whitespace-nowrap bg-red-500 text-white rounded p-2 font-medium"
        >
          Yes, delete my organization.
        </button>
      </div>
    </.modal>

    <.modal id="leave-organization-confirm">
      <div class="space-y-4">
        <p>
          Really leave <%= @current_organization.name %>? This is <span class="font-bold text-red-500">irreversible</span>.
        </p>
        <button
          phx-click="leave_organization"
          class="whitespace-nowrap bg-red-500 text-white rounded p-2 font-medium"
        >
          Yes, leave <%= @current_organization.name %>.
        </button>
      </div>
    </.modal>
    """
  end

  @impl true
  def handle_event("delete_organization", _params, socket) do
    # TODO: If org is personal organization, disallow
    HTTPizza.IAM.delete_organization(socket.assigns.current_organization)

    {:noreply, push_navigate(socket, to: ~p"/dashboard")}
  end

  @impl true
  def handle_event("leave_organization", _params, socket) do
    # TODO: If org is personal organization, disallow
    {:ok, _} =
      HTTPizza.IAM.get_organization_user_by_ids(
        socket.assigns.current_organization.id,
        socket.assigns.current_user.id
      )
      |> IO.inspect()
      |> HTTPizza.Repo.delete()

    {:noreply,
     socket
     |> push_navigate(to: ~p"/dashboard")
     |> put_flash(:info, "You have left #{socket.assigns.current_organization.name}")}
  end

  attr(:organization, Organization)
  attr(:current_user, User)
  attr(:personal, :boolean)
  attr(:label, :string)

  attr(:reason, :string,
    doc: "Reason to display in tooltip if disallowed (personal organization)"
  )

  attr(:on_click, :any)

  defp danger_button(%{personal: false} = assigns) do
    ~H"""
    <button
      phx-click={@on_click}
      disabled={@organization == @current_user.personal_organization}
      class="whitespace-nowrap bg-red-500 text-white rounded p-2 font-medium disabled:bg-red-500/40"
    >
      <%= @label %>
    </button>
    """
  end

  defp danger_button(%{personal: true} = assigns) do
    assigns =
      assigns
      |> assign(:assigns, Map.put(assigns, :personal, false))

    ~H"""
    <.tooltip id="delete-button-tooltip">
      <:trigger>
        <%= danger_button(@assigns) %>
      </:trigger>
      <p class="whitespace-nowrap"><%= @reason %></p>
    </.tooltip>
    """
  end

  defp danger_button(assigns) do
    assigns =
      assign(
        assigns,
        :personal,
        assigns.current_user.personal_organization == assigns.organization
      )

    danger_button(assigns)
  end
end
