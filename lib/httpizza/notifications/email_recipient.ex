defmodule HTTPizza.Notifications.EmailRecipient do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :ok, :boolean, default: false
    field :failed, :boolean, default: true
    field :error, :boolean, default: true
    field :email, :string
  end

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:email, :ok, :failed, :error])
    |> validate_required([:email, :ok, :failed, :error])
  end
end
