defmodule HTTPizzaWeb.InviteToTeamLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_organization == socket.assigns.current_user.personal_organization do
      {:ok, push_navigate(socket, to: ~p"/dashboard/personal")}
    else
      socket =
        with :ok <-
               HTTPizza.OrganizationPolicy.authorize(
                 "invite_user",
                 socket.assigns.current_user,
                 socket.assigns.current_organization
               ) do
          assign(socket, :form, to_form(%{}))
        else
          {:unauthorized, reason} ->
            socket
            |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/team")
            |> put_flash(:error, reason)
        end

      {:ok, socket}
    end
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
      path="/team"
    >
      <DashboardComponents.breadcrumbs
        organization={@current_organization}
        slug={@current_organization_slug}
        title="Team"
      />

      <div class="my-8">
        <.simple_form for={@form} id="invite-form" phx-submit="invite">
          <.input required field={@form[:email]} type="email" label="Email" phx-debounce="200" />

          <:actions>
            <button
              id="invite-button"
              phx-disable-with="Sending invite..."
              class="bg-orange-500 text-white rounded p-2"
            >
              Invite
            </button>
          </:actions>
        </.simple_form>
      </div>
    </.dashboard>
    """
  end

  @impl true
  def handle_event("invite", %{"email" => email}, socket) do
    case IAM.organization_has_user_by_email?(socket.assigns.current_organization, email) do
      true ->
        {:noreply, put_flash(socket, :error, "#{email} is already a team member")}

      _ ->
        {:ok, user} = maybe_register_user(email)

        {:ok, _} =
          IAM.deliver_user_invite_to_organization(
            user,
            socket.assigns.current_organization,
            &url(~p"/dashboard/#{socket.assigns.current_organization_slug}/team/join/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent to #{email}!")
         |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/team")}
    end
  end

  @spec maybe_register_user(String.t()) :: {:ok, %IAM.User{}} | {:error, Ecto.Changeset.t()}
  def maybe_register_user(email) do
    case IAM.get_user_by_email(email) do
      nil -> IAM.register_user(%{email: email, password: Ecto.UUID.generate()})
      user -> {:ok, user}
    end
  end
end
