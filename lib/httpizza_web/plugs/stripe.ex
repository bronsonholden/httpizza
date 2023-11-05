defmodule HTTPizzaWeb.Plugs.Stripe do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do
    [sig] = get_req_header(conn, "stripe-signature")
    body = conn.assigns[:raw_body]

    case Stripe.Webhook.construct_event(body, sig, System.get_env("STRIPE_WEBHOOK_SECRET")) do
      {:ok, _event} ->
        conn

      {:error, reason} ->
        conn
        |> resp(401, "Unauthorized: #{inspect(reason)}")
        |> halt()
    end
  end
end
