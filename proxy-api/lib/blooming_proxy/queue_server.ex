defmodule BoomingProxy.QueueServer do
  use GenServer
  use AMQP

  def start_link do
    args = [
      user: System.get_env("RABBIT_USER"),
      pass: System.get_env("RABBIT_PASS"),
      host: System.get_env("RABBIT_HOST"),
      port: System.get_env("RABBIT_PORT"),
    ]
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_clients do
    GenServer.call(__MODULE__, :clients)
    |> receive_message()
  end

  def get_invoices(client \\ nil) do
    GenServer.call(__MODULE__, {:invoices, client})
    |> receive_message()
  end

  defp receive_message(id) do
    receive do
      {^id, payload} ->
        IO.inspect payload, label: "payload"
        {:ok, payload}
    after 500 ->
        :timeout
    end
  end

  ## Server impl

  defp cfg, do: Application.get_env(:booming_proxy, :amqp)
  defp queues, do: Application.get_env(:booming_proxy, :queues)

  def init(args \\ []) do
    user = Keyword.get(args, :user) || cfg()[:user]
    pass = Keyword.get(args, :pass) || cfg()[:pass]
    host = Keyword.get(args, :host) || cfg()[:host]
    port = Keyword.get(args, :port) || cfg()[:port]

    broker_url = "amqp://#{user}:#{pass}@#{host}:#{port}"
    rand_id = gen_correlation_id()
    queue = "booming_proxy_queue_#{rand_id}"

    connect(broker_url, queue)
  end

  defp connect(url, queue) do
    case Connection.open(url) do
      {:ok, conn} ->
        # Get notifications when the connection goes down
        Process.monitor(conn.pid)

        {:ok, chan} = Channel.open(conn)
        Queue.declare(chan, queue, exclusive: true)
        Basic.qos(chan, prefetch_count: 1)
        {:ok, _consumer_tag} = Basic.consume(chan, queue, nil, no_ack: true)

        {:ok, %{chan: chan, url: url, queue: queue, replies: %{}}}

      _otherwise ->
        :timer.sleep(5_000)
        connect(url, queue)
    end
  end

  defp gen_correlation_id do
    :erlang.unique_integer
    |> :erlang.integer_to_binary
    |> Base.encode64
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _params}, state) do
    {:noreply, state}
  end

  # consumer is unexpectedly cancelled
  def handle_info({:basic_cancel, _params}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:basic_deliver, payload, meta}, state) do
    id = meta.correlation_id
    {from, replies} = Map.pop(state.replies, id)
    if from, do: send(from, {id, payload})

    {:noreply, %{state | replies: replies}}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    %{url: url, queue: queue} = state
    {:ok, state} = connect(url, queue)
    {:noreply, state}
  end

  def handle_call(:clients, {from, _tag}, state) do
    id = gen_correlation_id()
    replies = Map.put(state.replies, id, from)

    Basic.publish(state.chan,
      "",
      queues()[:clients],
      "give_me_clients",
      reply_to: state.queue,
      correlation_id: id
    )

    {:reply, id, Map.put(state, :replies, replies)}
  end

  def handle_call({:invoices, client}, {from, _tag}, state) do
    id = gen_correlation_id()
    replies = Map.put(state.replies, id, from)
    message = client && %{client_id: client} || %{}
    message_json = Poison.encode!(message)

    Basic.publish(state.chan,
      "",
      queues()[:invoices],
      message_json,
      reply_to: state.queue,
      correlation_id: id
    )

    {:reply, id, Map.put(state, :replies, replies)}
  end
end
