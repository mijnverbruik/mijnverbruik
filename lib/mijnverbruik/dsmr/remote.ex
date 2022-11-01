defmodule Mijnverbruik.DSMR.Remote do
  @moduledoc false
  use GenServer

  require Logger

  alias Mijnverbruik.DSMR.Adapter

  @behaviour Adapter

  @connect_timeout 5000
  @recv_timeout 5000

  @impl Adapter
  def start_link(parent_pid, opts) do
    GenServer.start_link(__MODULE__, {parent_pid, opts}, name: __MODULE__)
  end

  @impl GenServer
  def init({parent_pid, opts}) do
    {:ok, host} = parse_host(opts[:host])

    state = %{socket: nil, parent_pid: parent_pid, lines: ""}
    {:ok, state, {:continue, host: host, port: opts[:port]}}
  end

  @impl GenServer
  def handle_continue(opts, state) do
    socket_opts = [:binary, active: false, packet: :line]

    case :gen_tcp.connect(opts[:host], opts[:port], socket_opts, @connect_timeout) do
      {:ok, socket} ->
        send(self(), :recv_loop)
        {:noreply, %{state | socket: socket}}

      {:error, reason} ->
        Logger.error("Unable to connect to remote TCP socket - reason: #{inspect(reason)}")
        {:stop, :normal, state}
    end
  end

  @impl GenServer
  def handle_info(:recv_loop, state) do
    case :gen_tcp.recv(state.socket, 0, @recv_timeout) do
      {:ok, line} ->
        send(self(), {:recv_line, line})
        send(self(), :recv_loop)
        {:noreply, state}

      {:error, reason} ->
        Logger.error("TCP connection error - reason: #{inspect(reason)}")
        {:stop, :normal, state}
    end
  end

  @impl GenServer
  def handle_info({:recv_line, "!" <> _ = line}, state) do
    send(state.parent_pid, {:telegram, state.lines <> line})
    {:noreply, %{state | lines: ""}}
  end

  @impl GenServer
  def handle_info({:recv_line, line}, state) do
    {:noreply, %{state | lines: state.lines <> line}}
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
