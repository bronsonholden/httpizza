defmodule HTTPizzaWeb.HTTPListenersLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup do
    %{user: user_fixture()}
  end

  test "renders HTTP listeners for personal org", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)

    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/http-listeners")

    assert html
  end

  test "redirects if not authenticated", %{conn: conn} do
    result =
      live(conn, ~p"/dashboard/personal/http-listeners")
      |> follow_redirect(conn, ~p"/users/log_in")

    assert {:ok, conn} = result

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in to access this page"
  end

  test "redirects if viewing dashboard for org without access", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)
    organization = organization_fixture()

    result =
      live(conn, ~p"/dashboard/#{organization.slug}/http-listeners")
      |> follow_redirect(conn, ~p"/dashboard/personal")

    assert {:ok, _live_view, _html} = result
  end
end
