defmodule BoomingProxyWeb.ClientController do
  use BoomingProxyWeb, :controller
  alias BoomingProxy.QueueServer

  def index(conn, _params) do
    case QueueServer.get_clients do
      {:ok, payload} ->
        send_resp(conn, 200, payload)

      :timeout ->
        send_resp(conn, :gateway_timeout, "")
    end
  end
end
