defmodule HTTPizza.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false

  alias HTTPizza.Repo
  alias HTTPizza.IAM.Organization
  alias HTTPizza.Products.Subscription

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
  end

  def query_active_subscriptions_for_organization(organization) do
    customer_id = organization.customer_id

    from(s in Subscription,
      join: o in Organization,
      on: s.organization_id == o.id,
      where: o.customer_id == ^customer_id and s.status == :active
    )
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Gets a single active subscription for the organization given by its ID.

  Raises `Ecto.NoResultsError` if more than one Subscription exists

  ## Examples

      iex> get_organization_subscription!(123)
      %Subscription{}

      iex> get_organization_subscription!(456)
      nil

      iex> get_organization_subscription!(789)
      ** (Ecto.NoResultsError)

  """
  def get_organization_subscription!(organization_id) do
    now = DateTime.utc_now()

    from(s in Subscription,
      where:
        s.organization_id == ^organization_id and
          (s.status == :active or
             (s.status == :canceled and s.current_period_end > ^now))
    )
    |> Repo.one()
  end

  @doc """
  Gets a single subscription by `subscription_id` (the identifier for Stripe).

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_by_subscription_id!(subscription_id) do
    from(s in Subscription, where: s.subscription_id == ^subscription_id)
    |> Repo.one()
  end

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Delete all subscriptions with a status of `incomplete_expired`.
  """
  def delete_incomplete_expired_subscriptions() do
    from(s in Subscription, where: s.status == :incomplete_expired)
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end
end
