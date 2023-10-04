defmodule HTTPizza.ChecksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HTTPizza.Checks` context.
  """

  @doc """
  Generate an HTTP head check.
  """
  def http_head_check_fixture(attrs \\ %{}) do
    {:ok, http_head_check} =
      attrs
      |> Enum.into(%{
        value: "some value",
        header: "some header",
        comparator: :contains
      })
      |> HTTPizza.Checks.create_http_head_check()

    http_head_check
  end
end
