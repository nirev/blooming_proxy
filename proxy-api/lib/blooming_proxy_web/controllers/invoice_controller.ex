defmodule BoomingProxyWeb.InvoiceController do
  use BoomingProxyWeb, :controller
  alias BoomingProxy.QueueServer

  def index(conn, params) do
    client = params["client_id"]
    case QueueServer.get_invoices(client) do
      {:ok, payload} ->
        send_resp(conn, 200, payload)

      :timeout ->
        send_resp(conn, :gateway_timeout, "")
    end
  end
end
