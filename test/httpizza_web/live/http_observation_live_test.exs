defmodule HTTPizzaWeb.HTTPObservationLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.{IAMFixtures, ObserversFixtures}

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user), http_observer: http_observer_fixture()}
  end

  test "renders HTTP observation page", %{conn: conn, http_observer: http_observer} do
    http_observation =
      http_observation_fixture(%{
        http_observer_id: http_observer.id,
        status: :failed,
        reason: "Error: test error"
      })

    assert {:ok, _live_view, html} =
             live(conn, ~p"/dashboard/personal/http-observations/#{http_observation.id}")

    assert html =~ "Error: test error"
  end
end
