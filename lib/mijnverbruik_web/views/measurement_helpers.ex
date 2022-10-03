defmodule MijnverbruikWeb.Views.MeasurementHelpers do
  alias Mijnverbruik.Measurements.{Measurement, Summary}

  def electricity_currently_used(%Measurement{} = measurement) do
    Decimal.sub(
      measurement.electricity_currently_delivered,
      measurement.electricity_currently_returned
    )
  end

  def electricity_total_delivered(%Summary{} = summary) do
    Decimal.add(summary.electricity_delivered_1, summary.electricity_delivered_2)
  end

  def electricity_total_returned(%Summary{} = summary) do
    Decimal.add(summary.electricity_returned_1, summary.electricity_returned_2)
  end

  def electricity_total_used(%Summary{} = summary) do
    Decimal.sub(electricity_total_delivered(summary), electricity_total_returned(summary))
  end

  def to_kilowatt_hour(%Decimal{} = value), do: Decimal.round(value, 2)
  def to_kilowatt_hour(nil), do: to_kilowatt_hour(0)
  def to_kilowatt_hour(value), do: to_kilowatt_hour(Decimal.new(value))

  def to_watt(%Decimal{} = value), do: Decimal.mult(value, 1000) |> Decimal.to_integer()
  def to_watt(nil), do: to_watt(0)
  def to_watt(value), do: to_watt(Decimal.new(value))
end
