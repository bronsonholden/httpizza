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

  Raises `Ecto.NoResultsError` if the Http head check does not exist.

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
end
