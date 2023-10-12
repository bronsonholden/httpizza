defmodule HTTPizzaWeb.HTTPObservationLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.{IAMFixtures, ObserversFixtures}

  setup %{conn: conn} do
    user = user_fixture()
    organization = organization_fixture()

    %{
      conn: log_in_user(conn, user),
      user: user,
      http_observer: http_observer_fixture(%{organization: organization}),
      organization: organization
    }
  end

  test "renders HTTP observation page", %{
    conn: conn,
    user: user,
    organization: organization,
    http_observer: http_observer
  } do
    http_observation =
      http_observation_fixture(%{
        http_observer_id: http_observer.id,
        status: :failed,
        reason: "Error: test error"
      })

    organization_user_fixture(%{organization_id: organization.id, user_id: user.id})

    assert {:ok, _live_view, html} =
             live(
               conn,
               ~p"/dashboard/#{organization.slug}/http-observations/#{http_observation.id}"
             )

    assert html =~ "Error: test error"
  end

  test "redirects when viewing HTTP observation page for wrong organization", %{
    conn: conn,
    user: user,
    organization: organization,
    http_observer: http_observer
  } do
    http_observation =
      http_observation_fixture(%{
        http_observer_id: http_observer.id,
        status: :ok,
        reason: "All checks passed"
      })

    result =
      live(conn, ~p"/dashboard/personal/http-observations/#{http_observation.id}")
      |> follow_redirect(conn, ~p"/dashboard/personal")

    assert {:ok, _live_view, _html} = result

    # even if user has access to the org, it should redirect away since it's the wrong org
    organization_user_fixture(%{user_id: user.id, organization_id: organization.id})

    result =
      live(conn, ~p"/dashboard/personal/http-observations/#{http_observation.id}")
      |> follow_redirect(conn, ~p"/dashboard/personal")

    assert {:ok, _live_view, _html} = result
  end

  test "redirects when viewing HTTP observation page for organization without access", %{
    conn: conn,
    http_observer: http_observer,
    organization: organization
  } do
    http_observation =
      http_observation_fixture(%{
        http_observer_id: http_observer.id,
        status: :ok,
        reason: "All checks passed"
      })

    result =
      live(conn, ~p"/dashboard/#{organization.slug}/http-observations/#{http_observation.id}")
      |> follow_redirect(conn, ~p"/dashboard")

    assert {:ok, _conn} = result
  end
end
