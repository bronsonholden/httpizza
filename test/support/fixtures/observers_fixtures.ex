defmodule HTTPizza.ObserversFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HTTPizza.Observers` context.
  """

  @doc """
  Generate an HTTP Observer.
  """
  def http_observer_fixture(attrs \\ %{}) do
    {:ok, http_observer} =
      attrs
      |> Enum.into(%{
        https: false,
        port: 80,
        path: [],
        hostname: "example.com",
        schedule: "0 0 * * *",
        response_head_checks: ["200"]
      })
      |> HTTPizza.Observers.create_http_observer()

    http_observer
  end
end
