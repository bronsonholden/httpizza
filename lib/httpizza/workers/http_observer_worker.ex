defmodule HTTPizza.HTTPObserverWorker do
  use Oban.Worker, queue: :observers

  alias HTTPizza.Observers
  alias HTTPizza.Observers.{HTTPObserver, HTTPObservation}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    id
    |> Observers.get_http_observer!()
    |> observe()
  end

  def observe(%HTTPObserver{} = observer) do
    uri = build_uri(observer)

    {:ok, response} =
      Finch.build(observer.method, uri)
      |> Finch.request(HTTPizza.Finch)

    check_results =
      Enum.map(observer.http_head_checks, &HTTPizza.Service.validate_http_check(&1, response))

    status =
      check_results
      |> Enum.all?(fn
        %{status: :ok} -> true
        _ -> false
      end)
      |> case do
        true -> :ok
        _ -> :failed
      end

    {:ok, %{observation: observation}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :observation,
        observation_changeset(observer, %{status: status, check_results: check_results})
      )
      # |> Oban.insert() # notification job(s)
      |> HTTPizza.Repo.transaction()

    observation
  end

  # Process the observer and return an `Ecto.Changeset` for inserting the
  # resulting `HTTPObservation`
  @spec observation_changeset(%HTTPObserver{}, map()) :: Ecto.Changeset.t()
  defp observation_changeset(%HTTPObserver{} = observer, attrs) do
    %HTTPObservation{http_observer_id: observer.id}
    |> Observers.change_http_observation(attrs)
  end

  @spec build_uri(%HTTPObserver{}) :: String.t()
  defp build_uri(%HTTPObserver{} = observer) do
    URI.new!(%URI{
      host: observer.hostname,
      port: observer.port,
      path: observer.path,
      scheme: if(observer.https, do: "https", else: "http")
    })
    |> URI.to_string()
  end
end
