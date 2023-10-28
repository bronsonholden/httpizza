defmodule HTTPizzaWeb.HTTPObservationEmailTest do
  use HTTPizzaWeb.ConnCase

  alias HTTPizzaWeb.HTTPObservationEmail

  import HTTPizza.ObserversFixtures

  test "generates email for observation successes" do
    %{id: id} =
      http_observation_fixture(%{
        status: :ok,
        reason: "All checks successful"
      })

    http_observation =
      HTTPizza.Observers.get_http_observation!(id)
      |> HTTPizza.Repo.preload(http_observer: :organization)

    assert %{to: [{"", "johndoe@example.com"}]} =
             HTTPObservationEmail.report("johndoe@example.com", http_observation)
  end

  test "generates email for observation failures" do
    %{id: id} =
      http_observation_fixture(%{
        status: :failed,
        check_results: [
          %{
            status: :failed,
            reason: "Failed check for testing"
          }
        ]
      })

    http_observation =
      HTTPizza.Observers.get_http_observation!(id)
      |> HTTPizza.Repo.preload(http_observer: :organization)

    assert %{
             to: [{"", "johndoe@example.com"}],
             html_body: html_body
           } = HTTPObservationEmail.report("johndoe@example.com", http_observation)

    assert html_body =~ "failed: Failed check for testing"
  end

  test "generates email for observation errors" do
    %{id: id} =
      http_observation_fixture(%{
        status: :error,
        reason: "Something went wrong"
      })

    http_observation =
      HTTPizza.Observers.get_http_observation!(id)
      |> HTTPizza.Repo.preload(http_observer: :organization)

    assert %{to: [{"", "johndoe@example.com"}]} =
             HTTPObservationEmail.report("johndoe@example.com", http_observation)
  end
end
