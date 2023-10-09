defmodule HTTPizza.Checks do
  @moduledoc """
  The Checks context.
  """

  alias HTTPizza.Repo
  alias HTTPizza.Checks.HTTPStatusCheck

  import Ecto.Query, warn: false

  @doc """
  Returns the list of HTTP status checks.

  ## Examples

      iex> list_http_status_checks()
      [%HTTPStatusCheck{}, ...]

  """
  def list_http_status_checks do
    Repo.all(HTTPStatusCheck)
  end

  @doc """
  Gets a single http_status_check.

  Raises `Ecto.NoResultsError` if the HTTP status check does not exist.

  ## Examples

      iex> get_http_status_check!(123)
      %HTTPStatusCheck{}

      iex> get_http_status_check!(456)
      ** (Ecto.NoResultsError)

  """
  def get_http_status_check!(id), do: Repo.get!(HTTPStatusCheck, id)

  @doc """
  Creates an HTTP status check.

  ## Examples

      iex> create_http_status_check(%{field: value})
      {:ok, %HTTPStatusCheck{}}

      iex> create_http_status_check(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_http_status_check(attrs \\ %{}) do
    %HTTPStatusCheck{}
    |> HTTPStatusCheck.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an HTTP status check.

  ## Examples

      iex> update_http_status_check(http_status_check, %{field: new_value})
      {:ok, %HTTPStatusCheck{}}

      iex> update_http_status_check(http_status_check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_http_status_check(%HTTPStatusCheck{} = http_status_check, attrs) do
    http_status_check
    |> HTTPStatusCheck.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an HTTP status check.

  ## Examples

      iex> delete_http_status_check(http_status_check)
      {:ok, %HTTPStatusCheck{}}

      iex> delete_http_status_check(http_status_check)
      {:error, %Ecto.Changeset{}}

  """
  def delete_http_status_check(%HTTPStatusCheck{} = http_status_check) do
    Repo.delete(http_status_check)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking HTTP status check changes.

  ## Examples

      iex> change_http_status_check(http_status_check)
      %Ecto.Changeset{data: %HTTPStatusCheck{}}

  """
  def change_http_status_check(%HTTPStatusCheck{} = http_status_check, attrs \\ %{}) do
    HTTPStatusCheck.changeset(http_status_check, attrs)
  end
end
