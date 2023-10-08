defmodule HTTPizzaWeb.OrganizationLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup do
    %{user: user_fixture()}
  end

  test "renders personal organization settings page", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)

    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/settings")

    assert html
  end

  test "renders organization settings page", %{conn: conn, user: user} do
    organization = organization_fixture()
    organization_user_fixture(%{organization_id: organization.id, user_id: user.id})

    conn = log_in_user(conn, user)

    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/#{organization.slug}/settings")

    assert html
  end

  test "redirects from organization settings without access", %{conn: conn, user: user} do
    organization = organization_fixture()
    conn = log_in_user(conn, user)

    assert {:ok, _conn} =
             live(conn, ~p"/dashboard/#{organization.slug}/settings")
             |> follow_redirect(conn, ~p"/dashboard")
  end

  test "redirects from organization settings when unauthenticated", %{conn: conn} do
    organization = organization_fixture()

    assert {:ok, _conn} =
             live(conn, ~p"/dashboard/#{organization.slug}/settings")
             |> follow_redirect(conn, ~p"/users/log_in")
  end
end
