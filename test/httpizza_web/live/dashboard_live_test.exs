defmodule HTTPizzaWeb.DashboardLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders dashboard page", %{conn: conn} do
    {:ok, _live_view, html} = live(conn, ~p"/")

    assert html
  end
end
