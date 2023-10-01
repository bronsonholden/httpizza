defmodule HTTPizzaWeb.DashboardLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup do
    %{user: user_fixture()}
  end

  test "renders dashboard page", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)

    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard")

    assert html
  end

  test "redirects if not authenticated", %{conn: conn} do
    result =
      live(conn, ~p"/dashboard")
      |> follow_redirect(conn, ~p"/users/log_in")

    assert {:ok, conn} = result

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in to access this page"
  end
end
