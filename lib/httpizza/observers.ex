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

  @doc """
  Gets a single HTTP Observer.

  Raises `Ecto.NoResultsError` if the Http observer does not exist.

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
end
