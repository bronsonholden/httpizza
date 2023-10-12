defmodule HTTPizzaWeb.EditHTTPObserverLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.{IAMFixtures, ObserversFixtures}

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user)}
  end

  test "renders edit HTTP observer page", %{conn: conn} do
    http_observer = http_observer_fixture()

    assert {:ok, _live_view, html} =
             live(conn, ~p"/dashboard/personal/http-observers/#{http_observer.id}/edit")

    assert html
  end
end
