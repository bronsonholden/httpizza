defmodule HTTPizza.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HTTPizza.Products` context.
  """

  alias HTTPizza.IAMFixtures

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(attrs \\ %{})

  def subscription_fixture(%{organization: _} = attrs) do
    {:ok, subscription} =
      attrs
      |> Enum.into(%{
        status: :active,
        live: false,
        current_period_start: DateTime.utc_now(),
        current_period_end: DateTime.utc_now() |> DateTime.add(30, :day)
      })
      |> HTTPizza.Products.create_subscription()

    subscription
  end

  def subscription_fixture(attrs) do
    subscription_fixture(Map.put(attrs, :organization, IAMFixtures.organization_fixture()))
  end
end
