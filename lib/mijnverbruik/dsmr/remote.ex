defmodule Mijnverbruik.DSMR.Remote do
  @moduledoc false
  use GenServer

  require Logger

  alias Mijnverbruik.DSMR.Adapter

  @behaviour Adapter

  @impl Adapter
  def start_link(parent_pid, opts) do
    GenServer.start_link(__MODULE__, {parent_pid, opts}, name: __MODULE__)
  end

  @impl GenServer
  def init({parent_pid, opts}) do
    {:ok, host} = parse_host(opts[:host])

    state = %{socket: nil, parent_pid: parent_pid, telegram: ""}
    {:ok, state, {:continue, host: host, port: opts[:port]}}
  end

  @impl GenServer
  def handle_continue(opts, state) do
    socket_opts = [:binary, packet: 0, active: true, keepalive: true]

    case :gen_tcp.connect(opts[:host], opts[:port], socket_opts) do
      {:ok, socket} ->
        {:noreply, %{state | socket: socket}}

      {:error, reason} ->
        Logger.error("Unable to connect to remote TCP socket - reason: #{inspect(reason)}")
        {:stop, :normal, state}
    end
  end

  @impl GenServer
  def handle_info({:tcp, _socket, "!" <> _crc = line}, state) do
    telegram = state.telegram <> line
    send(state.parent_pid, {:telegram, telegram})

    {:noreply, %{state | telegram: ""}}
  end

  @impl GenServer
  def handle_info({:tcp, _socket, line}, state) do
    {:noreply, %{state | telegram: state.telegram <> line}}
  end

  @impl GenServer
  def handle_info({:tcp_closed, _socket}, state) do
    Logger.error("Remote TCP socket unexpectedly closed the connection")
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("Remote TCP socket unexpectedly errored - reason: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  defp parse_host(host) when is_binary(host) do
    parse_host(String.to_charlist(host))
  end

  defp parse_host(host) do
    case :inet.parse_address(host) do
      {:ok, ip} -> {:ok, ip}
      {:error, :einval} -> {:ok, host}
    end
  end
end
