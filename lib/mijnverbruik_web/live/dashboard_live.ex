defmodule MijnverbruikWeb.DashboardLive do
  use MijnverbruikWeb, :live_view

  alias Mijnverbruik.{Contracts, Measurements}
  alias Mijnverbruik.Measurements.{Measurement, Summary}
  alias MijnverbruikWeb.DashboardLive.ElectricityPanelComponent

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={ElectricityPanelComponent}
      id="electricity-panel"
      class="m-4"
      measurement={@measurement}
      daily_summary={@daily_summary}
      contract={@contract}
    />
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
      |> assign_contract()
      |> assign_daily_summary()
      |> assign_hourly_summary()
      |> assign_measurement()

    {:ok, socket}
  end

  @impl true
  def handle_info({:measurement, measurement}, socket) do
    {:noreply, assign(socket, measurement: measurement)}
  end

  defp assign_contract(socket) do
    assign_new(socket, :contract, fn -> Contracts.get_contract(1) end)
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
