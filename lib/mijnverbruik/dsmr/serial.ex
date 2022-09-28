defmodule Mijnverbruik.DSMR.Serial do
  @moduledoc false
  use GenServer

  alias Mijnverbruik.DSMR.Adapter

  @behaviour Adapter

  # This limits the restart rate for this GenServer on tty errors.
  # Errors usually mean the interface is going away and the relay
  # will clean things up soon. If nothing else, the UART won't be
  # pegged by restarts and the logs won't be filled with errors.
  @error_delay 1000

  @impl Adapter
  def start_link(parent_pid, opts) do
    GenServer.start_link(__MODULE__, {parent_pid, opts}, name: __MODULE__)
  end

  @impl GenServer
  def init({parent_pid, opts}) do
    tty = Keyword.fetch!(opts, :tty)

    {:ok, uart_pid} = Circuits.UART.start_link()

    uart_opts = [
      speed: 115_200,
      framing: {Circuits.UART.Framing.Line, separator: "\r\n"},
      rx_framing_timeout: 500
    ]

    state = %{uart_pid: uart_pid, tty: tty, parent_pid: parent_pid, telegram: ""}
    {:ok, state, {:continue, uart_opts}}
  end

  @impl GenServer
  def handle_continue(uart_opts, state) do
    case Circuits.UART.open(state.uart_pid, state.tty, uart_opts) do
      :ok ->
        {:noreply, state}

      {:error, _error} ->
        Process.sleep(@error_delay)
        {:stop, :tty_error, state}
    end
  end

  @impl GenServer
  def handle_info({:circuits_uart, _tty, {:partial, _fragment}}, state) do
    # dropping junk...
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _tty, {:error, _error}}, state) do
    Process.sleep(@error_delay)
    {:stop, :tty_error, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _tty, "!" <> _ = line}, state) do
    telegram = state.telegram <> line
    send(state.parent_pid, {:telegram, telegram})

    {:noreply, %{state | telegram: ""}}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _tty, line}, state) do
    {:noreply, %{state | telegram: state.telegram <> line}}
  end
end
