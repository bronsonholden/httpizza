defmodule HTTPizzaWeb.TeamLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()
    organization = organization_fixture(%{users: [user]})

    %{conn: log_in_user(conn, user), user: user, organization: organization}
  end

  test "renders team page", %{conn: conn, user: user, organization: organization} do
    {:ok, _live_view, html} = live(conn, ~p"/dashboard/#{organization.slug}/team")

    assert html =~ user.email
  end

  test "renders personal team page", %{conn: conn} do
    {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/team")

    assert html
  end

  test "redirects away from team page without access", %{conn: conn} do
    globex = organization_fixture(%{slug: "globex"})

    assert {:ok, _conn} =
             live(conn, ~p"/dashboard/#{globex.slug}/team")
             |> follow_redirect(conn, ~p"/dashboard")
  end
end
