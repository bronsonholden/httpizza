defmodule HTTPizza.Checks do
  @moduledoc """
  The Checks context.
  """

  import Ecto.Query, warn: false
  alias HTTPizza.Repo

  alias HTTPizza.Checks.HTTPHeadCheck

  @doc """
  Returns the list of HTTP head checks.

  ## Examples

      iex> list_http_head_checks()
      [%HTTPHeadCheck{}, ...]

  """
  def list_http_head_checks do
    Repo.all(HTTPHeadCheck)
  end

  @doc """
  Gets a single HTTP head check.

  Raises `Ecto.NoResultsError` if the HTTP head check does not exist.

  ## Examples

      iex> get_http_head_check!(123)
      %HTTPHeadCheck{}

      iex> get_http_head_check!(456)
      ** (Ecto.NoResultsError)

  """
  def get_http_head_check!(id), do: Repo.get!(HTTPHeadCheck, id)

  @doc """
  Creates an HTTP head check.

  ## Examples

      iex> create_http_head_check(%{field: value})
      {:ok, %HTTPHeadCheck{}}

      iex> create_http_head_check(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_http_head_check(attrs \\ %{}) do
    %HTTPHeadCheck{}
    |> HTTPHeadCheck.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an HTTP head check.

  ## Examples

      iex> update_http_head_check(http_head_check, %{field: new_value})
      {:ok, %HTTPHeadCheck{}}

      iex> update_http_head_check(http_head_check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_http_head_check(%HTTPHeadCheck{} = http_head_check, attrs) do
    http_head_check
    |> HTTPHeadCheck.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an HTTP head check.

  ## Examples

      iex> delete_http_head_check(http_head_check)
      {:ok, %HTTPHeadCheck{}}

      iex> delete_http_head_check(http_head_check)
      {:error, %Ecto.Changeset{}}

  """
  def delete_http_head_check(%HTTPHeadCheck{} = http_head_check) do
    Repo.delete(http_head_check)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking HTTP head check changes.

  ## Examples

      iex> change_http_head_check(http_head_check)
      %Ecto.Changeset{data: %HTTPHeadCheck{}}

  """
  def change_http_head_check(%HTTPHeadCheck{} = http_head_check, attrs \\ %{}) do
    HTTPHeadCheck.changeset(http_head_check, attrs)
  end

  alias HTTPizza.Checks.HTTPStatusCheck

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
