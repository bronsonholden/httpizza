defmodule HTTPizza.TestUtil do
  def time_travel(schema, timestamp \\ :inserted_at, to) do
    schema
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.cast(%{timestamp => to}, [timestamp])
    |> HTTPizza.Repo.update()
  end
end
