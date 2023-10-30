defmodule HTTPizzaWeb.NewHTTPListenerLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user)}
  end

  test "renders new HTTP listener page", %{conn: conn} do
    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/http-listeners/new")

    assert html
  end

  test "redirects when creating HTTP listener for organization without access", %{conn: conn} do
    organization = organization_fixture()

    result =
      live(conn, ~p"/dashboard/#{organization.slug}/http-listeners/new")
      |> follow_redirect(conn, ~p"/dashboard")

    assert {:ok, _conn} = result
  end
end
