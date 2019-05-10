defmodule Smache.TcpServer do
  use GenServer
  require Logger

  @tcp_options [:binary, packet: :line, active: false, reuseaddr: true]

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    init_stream()

    {:ok, []}
  end

  def init_stream do
    children = [{Task, fn -> accept(8793) end}]
    opts = [strategy: :one_for_one, name: Dipex.FlexStream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, @tcp_options)

    Logger.info("Accepting connections on port #{port}")

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
