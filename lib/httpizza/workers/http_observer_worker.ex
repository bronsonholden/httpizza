defmodule HTTPizza.HTTPObserverWorker do
  use Oban.Worker, queue: :observers, unique: [period: 60, fields: [:args, :worker]]

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

    result =
      Finch.build(observer.method, uri)
      |> Finch.request(HTTPizza.Finch)

    with {:ok, response} <- result do
      process_response(observer, response)
    else
      {:error, error} ->
        reason = "Error: #{Exception.message(error)}"

        {:ok, observation} =
          observation_changeset(observer, %{
            status: :failed,
            reason: reason
          })
          |> HTTPizza.Repo.insert()

        observation
    end
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

  defp process_response(%HTTPObserver{} = observer, %Finch.Response{} = response) do
    check_results =
      Enum.map(observer.header_checks, &HTTPizza.Service.validate_header_check(&1, response))

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

    reason =
      case status do
        :ok -> "All checks passed"
        :failed -> "One or more checks failed"
      end

    {:ok, %{observation: observation}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :observation,
        observation_changeset(observer, %{
          reason: reason,
          status: status,
          check_results: check_results
        })
      )
      # |> Oban.insert() # notification job(s)
      |> HTTPizza.Repo.transaction()

    observation
  end
end
