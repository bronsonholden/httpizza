defmodule HTTPizza.HTTPObserverWorker do
  use Oban.Worker, queue: :observers, unique: [period: 60, fields: [:args, :worker]]

  alias HTTPizza.Observers
  alias HTTPizza.Observers.{HTTPObserver, HTTPObservation}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    id
    |> Observers.get_http_observer!()
    |> observe()

    :ok
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

        changeset =
          observation_changeset(observer, %{
            status: :error,
            reason: reason
          })
          |> Ecto.Changeset.put_change(:id, Ecto.UUID.generate())

        multi =
          Ecto.Multi.new()
          |> Ecto.Multi.insert(
            :observation,
            changeset
          )

        observation_id = Ecto.Changeset.get_change(changeset, :id)

        multi =
          Enum.filter(observer.email_recipients, fn email_recipient ->
            email_recipient.error
          end)
          |> Enum.reduce(multi, fn email_recipient, multi ->
            Oban.insert(
              multi,
              :job,
              HTTPizza.Notifications.EmailNotification.Job.new(%{
                "recipient" => email_recipient.email,
                "http_observation_id" => observation_id
              })
            )
          end)

        {:ok, %{observation: observation}} =
          HTTPizza.Repo.transaction(multi)

        observation
    end
  end

  # Create an `Ecto.Changeset` for inserting an HTTP observation
  @spec observation_changeset(%HTTPObserver{}, map()) :: Ecto.Changeset.t()
  defp observation_changeset(%HTTPObserver{} = observer, attrs) do
    %HTTPObservation{http_observer_id: observer.id}
    |> Observers.change_http_observation(attrs)
    |> Ecto.Changeset.put_change(:id, Ecto.UUID.generate())
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
      [
        Enum.map(observer.header_checks, &HTTPizza.Service.validate_header_check(&1, response)),
        Enum.map(observer.status_checks, &HTTPizza.Service.validate_status_check(&1, response))
      ]
      |> Enum.concat()

    status =
      check_results
      |> Enum.all?(fn check_result_changeset ->
        Ecto.Changeset.get_field(check_result_changeset, :status) == :ok
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

    changeset =
      observation_changeset(observer, %{
        reason: reason,
        status: status,
        check_results: check_results
      })

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :observation,
        changeset
      )

    observation_id = Ecto.Changeset.get_change(changeset, :id)

    multi =
      Enum.reduce(observer.email_recipients, multi, fn email_recipient, multi ->
        if (email_recipient.ok and status == :ok) or
             (email_recipient.failed and status == :failed) do
          Oban.insert(
            multi,
            :job,
            HTTPizza.Notifications.EmailNotification.Job.new(%{
              "recipient" => email_recipient.email,
              "http_observation_id" => observation_id
            })
          )
        else
          multi
        end
      end)

    {:ok, %{observation: observation}} =
      multi
      |> HTTPizza.Repo.transaction()

    observation
  end
end
