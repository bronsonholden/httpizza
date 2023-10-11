defmodule HTTPizza.WorkersTest do
  use HTTPizza.DataCase

  alias HTTPizza.Observers.HTTPObservation

  describe "HTTPObserverWorker" do
    import HTTPizza.ObserversFixtures

    test "produces successful observation" do
      observer =
        http_observer_fixture(%{
          https: false,
          hostname: "htt.pizza",
          schedule: "0 0 * * *",
          header_checks: [
            %{comparator: :equal_to, header: "Location", value: "https://htt.pizza/"}
          ]
        })

      assert %HTTPObservation{
               status: :ok
             } = HTTPizza.HTTPObserverWorker.observe(observer)
    end

    test "produces successful observation for redirect status check" do
      observer =
        http_observer_fixture(%{
          https: false,
          hostname: "htt.pizza",
          schedule: "0 0 * * *",
          status_checks: [
            %{comparator: :is_redirect}
          ]
        })

      assert %HTTPObservation{
               status: :ok
             } = HTTPizza.HTTPObserverWorker.observe(observer)
    end

    test "produces failed observation" do
      observer =
        http_observer_fixture(%{
          https: false,
          hostname: "htt.pizza",
          schedule: "0 0 * * *",
          header_checks: [
            %{
              comparator: :not_equal_to,
              header: "Location",
              value: "https://htt.pizza/"
            }
          ]
        })

      assert %HTTPObservation{
               status: :failed
             } = HTTPizza.HTTPObserverWorker.observe(observer)
    end

    test "produces failed observation for successful status check" do
      observer =
        http_observer_fixture(%{
          https: false,
          hostname: "htt.pizza",
          schedule: "0 0 * * *",
          status_checks: [
            %{comparator: :is_success}
          ]
        })

      assert %HTTPObservation{
               status: :failed
             } = HTTPizza.HTTPObserverWorker.observe(observer)
    end
  end
end
