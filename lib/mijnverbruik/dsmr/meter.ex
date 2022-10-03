defmodule Mijnverbruik.DSMR.Meter do
  @moduledoc false
  use GenServer

  alias Mijnverbruik.Measurements

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    adapter = opts[:adapter] || Mijnverbruik.DSMR.Remote
    {:ok, adapter_pid} = adapter.start_link(self(), opts)

    state = %{adapter_pid: adapter_pid}
    {:ok, state}
  end

  @impl true
  def handle_info({:telegram, data}, state) do
    with {:ok, telegram} <- DSMR.parse(data),
         {:ok, measurement} <- Measurements.create_measurement(telegram) do
      :ok = Measurements.broadcast_measurement(measurement)
    else
      {:error, error} -> IO.inspect(error)
    end

    {:noreply, state}
  end
end
