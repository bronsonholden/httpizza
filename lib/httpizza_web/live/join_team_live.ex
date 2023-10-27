defmodule HTTPizzaWeb.JoinTeamLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"token" => token, "organization" => slug}, _session, socket) do
    organization = IAM.get_organization_by_slug!(slug)
    user = IAM.get_user_by_join_organization_token(token, organization)

    socket =
      socket
      |> assign(:token, token)
      |> assign(:user, user)
      |> assign(:organization, organization)
      |> assign(:form, to_form(%{}, as: "user"))

    {:ok,
     socket
     |> maybe_already_joined()
     |> maybe_different_user()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container size="sm">
      <.header class="text-center">Join <%= @organization.name %> on HTTPizza</.header>

      <.simple_form for={@form} id="join-form" phx-submit="join">
        <div :if={is_nil(@current_user) and is_nil(@user.last_logged_in_at)}>
          <.input
            field={@form[:password]}
            type="password"
            label="Password"
            required
            phx-debounce="200"
          />
          <.input
            field={@form[:password_confirmation]}
            type="password"
            label="Confirm password"
            required
            phx-debounce="200"
          />
        </div>
        <:actions>
          <.button id="join-button" phx-disable-with="Joining team..." class="w-full">
            Join <%= @organization.name %>
          </.button>
        </:actions>
      </.simple_form>
    </.container>
    """
  end

  @impl true
  def handle_event("join", params, socket) do
    case IAM.join_organization_multi(socket.assigns.organization.id, socket.assigns.token) do
      {:ok, multi} ->
        multi =
          if params["user"] do
            user_params = params["user"]

            Ecto.Multi.update(
              multi,
              :user,
              IAM.User.password_changeset(socket.assigns.user, %{
                "password" => user_params["password"],
                "password_confirmation" => user_params["password_confirmation"]
              })
            )
          else
            multi
          end

        with {:ok, _} <- HTTPizza.Repo.transaction(multi) do
          if socket.assigns[:current_user] do
            {:noreply,
             socket
             |> put_flash(:info, "Welcome to the #{socket.assigns.organization.name} team!")
             |> push_navigate(to: ~p"/dashboard/#{socket.assigns.organization.slug}")}
          else
            {:noreply,
             socket
             |> put_flash(
               :info,
               "Thanks for joining #{socket.assigns.organization.name}! Sign in to get started."
             )
             |> push_navigate(to: ~p"/users/log_in")}
          end
        else
          {:error, :user, changeset, _} ->
            changeset =
              changeset
              |> Map.put(:action, :validate)

            {:noreply, assign_form(socket, changeset)}
        end

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "Join link is invalid or it has expired.")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    password_params = Map.take(user_params, ["password", "password_confirmation"])

    changeset =
      socket.assigns.user
      |> IAM.change_user_password(password_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  defp assign_form(socket, changeset) do
    assign(socket,
      form: to_form(changeset, as: "user")
    )
  end

  # if the user has already joined the organization, redirect and notify appropriately
  def maybe_already_joined(socket) do
    if IAM.organization_has_user_by_email?(socket.assigns.organization, socket.assigns.user.email) do
      case socket.assigns[:current_user] do
        nil ->
          socket
          |> put_flash(:error, "Invitation has already been accepted. Please log in.")
          |> push_navigate(to: ~p"/users/log_in")

        _ ->
          socket
          |> put_flash(:error, "You are already a member of #{socket.assigns.organization.name}.")
          |> push_navigate(to: ~p"/dashboard/#{socket.assigns.organization.slug}")
      end
    else
      socket
    end
  end

  # if the browser is logged in as a different user, redirect away
  def maybe_different_user(%{assigns: %{current_user: nil}} = socket), do: socket

  def maybe_different_user(socket) do
    if socket.assigns.current_user.id != socket.assigns.user.id do
      socket
      |> put_flash(:error, "This invite link is not valid for your account.")
      |> push_navigate(to: ~p"/dashboard/personal")
    else
      socket
    end
  end
end
