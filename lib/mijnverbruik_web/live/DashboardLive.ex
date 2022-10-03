defmodule MijnverbruikWeb.DashboardLive do
  use MijnverbruikWeb, :live_view

  alias Mijnverbruik.Measurements
  alias Mijnverbruik.Measurements.Measurement

  def render(assigns) do
    ~H"""
    <h1>Dashboard</h1>
    <dl>
      <dt>
        Electricity Currently Used
      </dt>
      <dd>
        <%= @measurement.electricity_currently_delivered %> W
      </dd>
      <dt>
        Electricity Currently Returned
      </dt>
      <dd>
      <%= @measurement.electricity_currently_returned %> W
      </dd>
    </dl>
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
