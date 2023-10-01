defmodule HTTPizzaWeb.LandingLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup do
    %{user: user_fixture()}
  end

  test "renders landing page", %{conn: conn} do
    {:ok, _live_view, html} = live(conn, ~p"/")

    assert html
  end

  test "redirects if authenticated", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)

    result =
      live(conn, ~p"/")
      |> follow_redirect(conn, ~p"/dashboard")

    assert {:ok, conn} = result

    # assert quiet redirect
    refute Phoenix.Flash.get(conn.assigns.flash, :info)
    refute Phoenix.Flash.get(conn.assigns.flash, :error)
  end
end
