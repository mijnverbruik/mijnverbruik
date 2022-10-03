defmodule Mijnverbruik.UpdateSummaries do
  @moduledoc false

  use GenServer

  alias Mijnverbruik.Measurements

  @quarter_hour_in_ms 15 * 60 * 1000

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    state = %{
      timer_ref: nil
    }

    {:ok, schedule_update(state, 0)}
  end

  @impl true
  def handle_info(:update, state) do
    :ok = Measurements.summarize_last_hour()
    :ok = Measurements.summarize_last_day()

    {:noreply, schedule_update(state, @quarter_hour_in_ms)}
  end

  defp schedule_update(state, time) do
    timer_ref = Process.send_after(self(), :update, time)
    %{state | timer_ref: timer_ref}
  end
end
