defmodule Mijnverbruik.DSMR.Remote do
  @moduledoc false
  use GenServer

  alias Mijnverbruik.DSMR.Adapter

  @behaviour Adapter

  @impl Adapter
  def start_link(parent_pid, opts) do
    GenServer.start_link(__MODULE__, {parent_pid, opts}, name: __MODULE__)
  end

  @impl GenServer
  def init({parent_pid, opts}) do
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)

    {:ok, host} = parse_host(host)

    state = %{socket: nil, parent_pid: parent_pid, telegram: ""}
    {:ok, state, {:continue, host: host, port: port}}
  end

  @impl GenServer
  def handle_continue(socket_opts, state) do
    {:ok, socket} =
      :gen_tcp.connect(socket_opts[:host], socket_opts[:port], [:binary, packet: 0, active: true])

    {:noreply, %{state | socket: socket}}
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
