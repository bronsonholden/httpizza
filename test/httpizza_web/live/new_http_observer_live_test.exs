defmodule HTTPizzaWeb.NewHTTPObserverLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user)}
  end

  test "renders new HTTP observer page", %{conn: conn} do
    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/http-observers/new")

    assert html
  end
end
