defmodule HTTPizzaWeb.Organization do
  use HTTPizzaWeb, :verified_routes

  alias HTTPizza.IAM

  @doc """
  Handles mounting selected organization for LiveViews where a selected
  organization is applicable.

  ## `on_mount` arguments

    * `:mount_current_organization` - Mount `current_organization` if the
      organization exists and the `current_user` socket assign has access.

    * `:ensure_organization_selected` - Assigns `current_organizaiton` based
      on the `organization` parameter, but only if the organization exists and
      the `current_user` socket assign has access. Redirects to the dashboard if
      no such organization exists.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to assign the current organization

      defmodule HTTPizzaWeb.PageLive do
        use HTTPizzaWeb, :live_view

        on_mount {HTTPizzaWeb.Organization, :ensure_current_organization}
        ...
      end
  """
  def on_mount(:mount_current_organization, params, _sessionn, socket) do
    {:cont, maybe_mount_current_organization(socket, params)}
  end

  def on_mount(:ensure_organization_selected, params, _session, socket) do
    socket = maybe_mount_current_organization(socket, params)

    if socket.assigns.current_organization do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/dashboard")}
    end
  end

  defp maybe_mount_current_organization(
         %{assigns: %{current_user: %IAM.User{} = current_user}} = socket,
         params
       ) do
    Phoenix.Component.assign_new(socket, :current_organization, fn ->
      case params["organization"] do
        "personal" -> current_user.personal_organization
        nil -> nil
        slug -> HTTPizza.IAM.get_user_organization_by_slug(current_user, slug)
      end
    end)
  end

  defp maybe_mount_current_organization(socket, _params), do: socket
end
