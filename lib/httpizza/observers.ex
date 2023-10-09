defmodule HTTPizza.Observers do
  @moduledoc """
  The Observers context.
  """

  import Ecto.Query, warn: false

  alias HTTPizza.Repo
  alias HTTPizza.Observers.HTTPObserver

  @doc """
  Returns the list of HTTP Observers.

  ## Examples

      iex> list_http_observers()
      [%HTTPObserver{}, ...]

  """
  def list_http_observers do
    Repo.all(HTTPObserver)
  end

  @doc """
  Returns the list of HTTP Observers associated with the given organization by `id`.
  """
  def list_organization_http_observers(organization_id) do
    from(o in HTTPObserver,
      where:
        o.organization_id ==
          ^organization_id
    )
    |> Repo.all()
  end

  def list_http_observers_past_scheduled_run() do
    now = DateTime.utc_now()

    from(o in HTTPObserver,
      where: is_nil(o.scheduled_at) or fragment("? <= ?", o.scheduled_at, ^now)
    )
    |> Repo.all()
  end

  @doc """
  Gets a single HTTP Observer.

  Raises `Ecto.NoResultsError` if the HTTP observer does not exist.

  ## Examples

      iex> get_http_observer!(123)
      %HTTPObserver{}

      iex> get_http_observer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_http_observer!(id), do: Repo.get!(HTTPObserver, id)

  @doc """
  Creates an HTTP Observer.

  ## Examples

      iex> create_http_observer(%{field: value})
      {:ok, %HTTPObserver{}}

      iex> create_http_observer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_http_observer(attrs \\ %{}) do
    %HTTPObserver{}
    |> HTTPObserver.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an HTTP Observer.

  ## Examples

      iex> update_http_observer(http_observer, %{field: new_value})
      {:ok, %HTTPObserver{}}

      iex> update_http_observer(http_observer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_http_observer(%HTTPObserver{} = http_observer, attrs) do
    http_observer
    |> HTTPObserver.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an HTTP Observer.

  ## Examples

      iex> delete_http_observer(http_observer)
      {:ok, %HTTPObserver{}}

      iex> delete_http_observer(http_observer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_http_observer(%HTTPObserver{} = http_observer) do
    Repo.delete(http_observer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking HTTP Observer changes.

  ## Examples

      iex> change_http_observer(http_observer)
      %Ecto.Changeset{data: %HTTPObserver{}}

  """
  def change_http_observer(%HTTPObserver{} = http_observer, attrs \\ %{}) do
    HTTPObserver.changeset(http_observer, attrs)
  end

  alias HTTPizza.Observers.HTTPObservation

  @doc """
  Returns the list of http_observations.

  ## Examples

      iex> list_http_observations()
      [%HTTPObservation{}, ...]

  """
  def list_http_observations do
    Repo.all(HTTPObservation)
  end

  @doc """
  Gets a single http_observation.

  Raises `Ecto.NoResultsError` if the HTTP observation does not exist.

  ## Examples

      iex> get_http_observation!(123)
      %HTTPObservation{}

      iex> get_http_observation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_http_observation!(id), do: Repo.get!(HTTPObservation, id)

  @doc """
  Creates a http_observation.

  ## Examples

      iex> create_http_observation(%{field: value})
      {:ok, %HTTPObservation{}}

      iex> create_http_observation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_http_observation(attrs \\ %{}) do
    %HTTPObservation{}
    |> HTTPObservation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a http_observation.

  ## Examples

      iex> update_http_observation(http_observation, %{field: new_value})
      {:ok, %HTTPObservation{}}

      iex> update_http_observation(http_observation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_http_observation(%HTTPObservation{} = http_observation, attrs) do
    http_observation
    |> HTTPObservation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a http_observation.

  ## Examples

      iex> delete_http_observation(http_observation)
      {:ok, %HTTPObservation{}}

      iex> delete_http_observation(http_observation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_http_observation(%HTTPObservation{} = http_observation) do
    Repo.delete(http_observation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking http_observation changes.

  ## Examples

      iex> change_http_observation(http_observation)
      %Ecto.Changeset{data: %HTTPObservation{}}

  """
  def change_http_observation(%HTTPObservation{} = http_observation, attrs \\ %{}) do
    HTTPObservation.changeset(http_observation, attrs)
  end
end
