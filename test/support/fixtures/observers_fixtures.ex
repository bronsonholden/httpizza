defmodule HTTPizza.ObserversFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HTTPizza.Observers` context.
  """

  alias HTTPizza.IAMFixtures

  @doc """
  Generate an HTTP Observer.
  """
  def http_observer_fixture(attrs \\ %{})

  def http_observer_fixture(%{organization: _} = attrs) do
    {:ok, http_observer} =
      attrs
      |> Enum.into(%{
        https: false,
        port: 80,
        path: "/",
        hostname: "example.com",
        schedule: "0 0 * * *",
        method: :get
      })
      |> HTTPizza.Observers.create_http_observer()

    http_observer
  end

  def http_observer_fixture(attrs) do
    http_observer_fixture(Map.put(attrs, :organization, IAMFixtures.organization_fixture()))
  end

  @doc """
  Generate a http_observation.
  """
  def http_observation_fixture(attrs \\ %{})

  def http_observation_fixture(%{http_observer_id: _} = attrs) do
    {:ok, http_observation} =
      attrs
      |> Enum.into(%{
        status: :ok,
        started_at: ~U[2023-10-05 02:42:00Z],
        duration: 42
      })
      |> HTTPizza.Observers.create_http_observation()

    http_observation
  end

  def http_observation_fixture(attrs) do
    http_observer = http_observer_fixture()

    attrs
    |> Map.put(:http_observer_id, http_observer.id)
    |> http_observation_fixture()
  end
end
