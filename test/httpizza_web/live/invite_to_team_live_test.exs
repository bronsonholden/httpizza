defmodule HTTPizzaWeb.InviteToTeamLiveTest do
  use HTTPizzaWeb.ConnCase

  alias HTTPizza.IAM

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()
    organization = organization_fixture(%{users: [user]})

    %{conn: log_in_user(conn, user), user: user, organization: organization}
  end

  test "renders invite to team page", %{conn: conn, organization: organization} do
    {:ok, _live_view, html} = live(conn, ~p"/dashboard/#{organization.slug}/team/invite")

    assert html
  end

  test "redirects from invite to personal organization", %{conn: conn} do
    {:ok, _live_view, html} =
      live(conn, ~p"/dashboard/personal/team/invite")
      |> follow_redirect(conn, ~p"/dashboard/personal")

    assert html
  end

  test "invites a new team member", %{conn: conn, organization: organization} do
    {:ok, live_view, _html} = live(conn, ~p"/dashboard/#{organization.slug}/team/invite")

    assert IAM.list_user_tokens_for_context("join:#{organization.id}") == []

    {:ok, _live_view, html} =
      live_view
      |> render_submit("invite", %{"email" => "johndoe@example.com"})
      |> follow_redirect(conn, ~p"/dashboard/#{organization.slug}/team")

    assert html =~ "Invitation sent to johndoe@example.com"
    assert %{id: user_id} = IAM.get_user_by_email("johndoe@example.com")
    assert [%{user_id: ^user_id}] = IAM.list_user_tokens_for_context("join:#{organization.id}")
  end

  test "does not invite an existing team member", %{conn: conn, organization: organization} do
    user = user_fixture(%{email: "johndoe@example.com"})
    organization_user_fixture(%{organization_id: organization.id, user_id: user.id})

    {:ok, live_view, _html} = live(conn, ~p"/dashboard/#{organization.slug}/team/invite")

    assert IAM.list_user_tokens_for_context("join:#{organization.id}") == []

    assert live_view
           |> render_submit("invite", %{"email" => "johndoe@example.com"}) =~
             "johndoe@example.com is already a team member"

    assert IAM.list_user_tokens_for_context("join:#{organization.id}") == []
  end
end
