defmodule HTTPizzaWeb.TeamLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       :organization_users,
       IAM.list_organization_team(socket.assigns.current_organization)
     )}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_uri, uri)}
  end

  @impl true
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
      path="/team"
    >
      <div class="flex items-start justify-between w-full">
        <DashboardComponents.breadcrumbs
          organization={@current_organization}
          slug={@current_organization_slug}
          title="Team"
        />
        <.invite_link
          current_organization_slug={@current_organization_slug}
          organization={@current_organization}
          current_user={@current_user}
        />
      </div>

      <table class="my-8 border w-full">
        <thead class="text-sm">
          <tr>
            <th class="text-left text-stone-500 dark:text-stone-400 border border-stone-200 dark:border-stone-700 p-2">
              Email
            </th>
            <th class="text-left text-stone-500 dark:text-stone-400 border border-stone-200 dark:border-stone-700 p-2">
              Joined
            </th>
          </tr>
        </thead>
        <tr :for={%{inserted_at: inserted_at, user: user} <- @organization_users} class="border">
          <td class="border border-stone-200 dark:border-stone-700 p-2"><%= user.email %></td>
          <td class="border border-stone-200 dark:border-stone-700 p-2">
            <%= Timex.format!(inserted_at, "{Mshort} {0D}, {YYYY}") %>
          </td>
        </tr>
      </table>
    </.dashboard>
    """
  end

  defp invite_link(%{disabled: false} = assigns) do
    ~H"""
    <.link
      class="h-full py-1 pl-1 pr-2 text-xs font-bold hover:bg-orange-400 rounded text-white bg-orange-500 flex items-center gap-1"
      navigate={~p"/dashboard/#{@current_organization_slug}/team/invite"}
    >
      <.icon name="hero-user-plus-mini" class="scale-75" /> Invite
    </.link>
    """
  end

  defp invite_link(%{disabled: true, reason: _reason} = assigns) do
    ~H"""
    <.tooltip id="delete-button-tooltip">
      <:trigger>
        <button
          type="button"
          disabled
          class="h-full py-1 pl-1 pr-2 text-xs font-bold bg-orange-400/80 rounded text-stone-100 dark:text-stone-300/70 flex items-center gap-1"
        >
          <.icon name="hero-user-plus-mini" class="scale-75" /> Invite
        </button>
      </:trigger>
      <p class="whitespace-nowrap"><%= @reason %></p>
    </.tooltip>
    """
  end

  defp invite_link(assigns) do
    assigns =
      assigns
      |> assign(:disabled, false)
      |> assign(:reason, nil)

    assigns =
      if assigns.current_user.personal_organization == assigns.organization do
        assigns
        |> assign(
          :disabled,
          assigns.current_user.personal_organization == assigns.organization
        )
        |> assign(:reason, "Can't invite to your personal organization")
      else
        assigns
      end

    assigns =
      with :ok <-
             HTTPizza.OrganizationPolicy.authorize(
               "invite_user",
               assigns.current_user,
               assigns.organization
             ) do
        assigns
      else
        {:unauthorized, reason} ->
          assigns
          |> assign(:disabled, true)
          |> assign(:reason, reason)
      end

    invite_link(assigns)
  end
end
