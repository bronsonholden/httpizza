defmodule HTTPizzaWeb.OrganizationTest do
  use HTTPizzaWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias HTTPizza.IAM
  alias HTTPizzaWeb.Organization
  alias HTTPizzaWeb.UserAuth

  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, HTTPizzaWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    user = user_fixture()
    user_token = IAM.generate_user_session_token(user)

    session =
      conn
      |> put_session(:user_token, user_token)
      |> get_session()

    {:cont, socket} =
      UserAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

    %{conn: conn, user: user, session: session, socket: socket}
  end

  describe "on_mount: mount_current_organization" do
    test "assigns personal organization", %{session: session, socket: socket} do
      {:cont, socket} =
        Organization.on_mount(
          :mount_current_organization,
          %{"organization" => "personal"},
          session,
          socket
        )

      assert socket.assigns.current_organization.id ==
               socket.assigns.current_user.personal_organization.id
    end

    test "empty assign when no organization found", %{session: session, socket: socket} do
      {:cont, socket} =
        Organization.on_mount(
          :mount_current_organization,
          %{"organization" => "not-your-org"},
          session,
          socket
        )

      refute socket.assigns[:current_organization]
    end

    test "assigns an associated organization", %{user: user, session: session, socket: socket} do
      organization = organization_fixture()
      organization_user_fixture(%{user_id: user.id, organization_id: organization.id})

      {:cont, socket} =
        Organization.on_mount(
          :mount_current_organization,
          %{"organization" => organization.slug},
          session,
          socket
        )

      assert socket.assigns.current_organization.id == organization.id
    end
  end

  describe "on_mount: ensure_organization_selected" do
    test "assigns personal organization", %{session: session, socket: socket} do
      {:cont, socket} =
        Organization.on_mount(
          :ensure_organization_selected,
          %{"organization" => "personal"},
          session,
          socket
        )

      assert socket.assigns.current_organization.id ==
               socket.assigns.current_user.personal_organization.id
    end

    test "redirects if no matching organization found", %{session: session, socket: socket} do
      {:halt, socket} =
        Organization.on_mount(
          :ensure_organization_selected,
          %{"organization" => "not-your-org"},
          session,
          socket
        )

      refute socket.assigns[:current_organization]
    end

    test "assigns an associated organization", %{user: user, session: session, socket: socket} do
      organization = organization_fixture()
      organization_user_fixture(%{user_id: user.id, organization_id: organization.id})

      {:cont, socket} =
        Organization.on_mount(
          :ensure_organization_selected,
          %{"organization" => organization.slug},
          session,
          socket
        )

      assert socket.assigns.current_organization.id == organization.id
    end
  end
end
