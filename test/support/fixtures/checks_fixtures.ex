defmodule HTTPizza.ChecksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HTTPizza.Checks` context.
  """

  @doc """
  Generate an HTTP status check.
  """
  def http_status_check_fixture(attrs \\ %{}) do
    {:ok, http_status_check} =
      attrs
      |> Enum.into(%{
        code: "200",
        comparator: :is_exactly
      })
      |> HTTPizza.Checks.create_http_status_check()

    http_status_check
  end
end
