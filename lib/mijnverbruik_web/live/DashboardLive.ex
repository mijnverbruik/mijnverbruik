defmodule MijnverbruikWeb.DashboardLive do
  use MijnverbruikWeb, :live_view

  alias Mijnverbruik.Measurements
  alias Mijnverbruik.Measurements.Measurement

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-sm p-4 m-4">
      <h2 class="border-b border-gray-100 font-bold pb-2">
        Electricity Balance
      </h2>
      <div class="flex text-center mt-2">
        <div class="space-y-1 w-1/3">
          <div>
            <span class="text-lg font-bold">
              <%= @measurement.electricity_currently_delivered %> W
            </span>
            <span class="text-xs">
              W
            </span>
          </div>
          <div class="text-sm text-gray-500">
            Realtime
          </div>
        </div>

        <div class="space-y-1 w-1/3">
          <div>
            <span class="text-lg font-bold">
              <%= @measurement.electricity_currently_delivered %> W
            </span>
            <span class="text-xs">
              kWh
            </span>
          </div>
          <div class="text-sm text-gray-500">
            Today
          </div>
        </div>

        <div class="space-y-1 w-1/3">
          <div>
            <span class="text-lg font-bold">
              <%= @measurement.electricity_currently_delivered %> W
            </span>
            <span class="text-xs">
              kWh
            </span>
          </div>
          <div class="text-sm text-gray-500">
            Cost
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Measurements.subscribe()
    end

    socket =
      socket
      |> assign_measurement()

    {:ok, socket}
  end

  def handle_info({:measurement, measurement}, socket) do
    {:noreply, assign(socket, measurement: measurement)}
  end

  defp assign_measurement(socket) do
    with %Measurement{} = measurement <- Measurements.get_latest_measurement() do
      assign(socket, :measurement, measurement)
    else
      _ -> assign(socket, :measurement, %Measurement{})
    end
  end
end
