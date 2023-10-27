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
end
