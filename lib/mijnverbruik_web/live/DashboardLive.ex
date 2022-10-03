defmodule MijnverbruikWeb.DashboardLive do
  use MijnverbruikWeb, :live_view

  alias Mijnverbruik.Measurements
  alias Mijnverbruik.Measurements.{Measurement, Summary}
  alias MijnverbruikWeb.Views.MeasurementHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <div id="electricity-balance" class="bg-white rounded-lg shadow-sm p-4 m-4">
      <h2 class="border-b border-gray-100 font-bold pb-2">
        Electricity Balance
      </h2>
      <div class="flex text-center mt-2">
        <div class="space-y-1 w-1/3">
          <div class="realtime">
            <span class="text-lg font-bold">
              <%= MeasurementHelpers.electricity_currently_used(@measurement) |> MeasurementHelpers.to_watt() %>
            </span>
            <span class="text-xs">
              W
            </span>
          </div>
          <div class="text-sm text-gray-500">
            <%= gettext "Realtime" %>
          </div>
        </div>

        <div class="space-y-1 w-1/3">
          <div class="today">
            <span class="text-lg font-bold">
              <%= MeasurementHelpers.electricity_total_used(@daily_summary) |> MeasurementHelpers.to_kilowatt_hour() %>
            </span>
            <span class="text-xs">
              kWh
            </span>
          </div>
          <div class="text-sm text-gray-500">
            <%= gettext "Today" %>
          </div>
        </div>

        <div class="space-y-1 w-1/3">
          <div class="cost">
            <span class="text-lg font-bold">
              <%= @measurement.electricity_currently_delivered %>
            </span>
            <span class="text-xs">
              kWh
            </span>
          </div>
          <div class="text-sm text-gray-500">
            <%= gettext "Cost" %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Measurements.subscribe()
    end

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign_daily_summary()
      |> assign_hourly_summary()
      |> assign_measurement()

    {:ok, socket}
  end

  @impl true
  def handle_info({:measurement, measurement}, socket) do
    {:noreply, assign(socket, measurement: measurement)}
  end

  defp assign_daily_summary(socket) do
    assign_new(socket, :daily_summary, fn ->
      with %Summary{} = summary <- Measurements.get_summary_for_24h(DateTime.utc_now()) do
        summary
      else
        _ -> %Summary{}
      end
    end)
  end

  defp assign_hourly_summary(socket) do
    assign_new(socket, :hourly_summary, fn ->
      with %Summary{} = summary <- Measurements.get_summary_for_60m(DateTime.utc_now()) do
        summary
      else
        _ -> %Summary{}
      end
    end)
  end

  defp assign_measurement(socket) do
    with %Measurement{} = measurement <- Measurements.get_latest_measurement() do
      assign(socket, :measurement, measurement)
    else
      _ -> assign(socket, :measurement, %Measurement{})
    end
  end
end
