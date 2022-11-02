defmodule MijnverbruikWeb.DashboardLive.ElectricityPanelComponent do
  use MijnverbruikWeb, :live_component

  alias MijnverbruikWeb.Views.MeasurementHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class={["bg-white rounded-lg shadow-sm p-4", @class]}>
      <h2 class="border-b border-gray-100 font-bold pb-2">
        <%= gettext "Electricity" %>
      </h2>
      <div class="flex text-center mt-2">
        <div class="space-y-1 w-1/3">
          <div>
            <.animated_value id="electricity-realtime-value" class="text-lg font-bold">
              <%= @currently_used %>
            </.animated_value>
            <span class="text-xs">
              W
            </span>
          </div>
          <div class="text-sm text-gray-500">
            <%= gettext "Realtime" %>
          </div>
        </div>

        <div class="space-y-1 w-1/3">
          <div>
            <span class="text-lg font-bold">
              <%= @total_used %>
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
          <%= if @total_cost do %>
            <div>
              <span class="text-xs">
                <%= Money.Currency.symbol(@total_cost.currency) %>
              </span>
              <span class="text-lg font-bold">
                <%= MeasurementHelpers.to_money(@total_cost) %>
              </span>
            </div>
          <% else %>
            <div>
              <span class="text-lg font-bold">
                &#133;
              </span>
            </div>
          <% end %>
          <div class="text-sm text-gray-500">
            <%= gettext "Cost" %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:class, assigns.class)
      |> assign_currently_used(assigns)
      |> assign_total_used(assigns)
      |> assign_total_cost(assigns)

    {:ok, socket}
  end

  defp assign_currently_used(socket, assigns) do
    assign(
      socket,
      :currently_used,
      MeasurementHelpers.electricity_currently_used(assigns.measurement)
      |> MeasurementHelpers.to_watt()
    )
  end

  defp assign_total_used(socket, assigns) do
    assign(
      socket,
      :total_used,
      MeasurementHelpers.electricity_total_used(assigns.daily_summary)
      |> MeasurementHelpers.to_kilowatt_hour()
    )
  end

  defp assign_total_cost(socket, %{contract: nil}) do
    assign(socket, :total_cost, nil)
  end

  defp assign_total_cost(socket, assigns) do
    assign(
      socket,
      :total_cost,
      Money.subtract(
        MeasurementHelpers.electricity_total_cost(assigns.daily_summary, assigns.contract),
        MeasurementHelpers.electricity_total_yield(assigns.daily_summary, assigns.contract)
      )
    )
  end
end
