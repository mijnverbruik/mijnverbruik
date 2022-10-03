defmodule Mijnverbruik.MeasurementsTest do
  use Mijnverbruik.DataCase, async: true

  alias Mijnverbruik.Measurements
  alias Mijnverbruik.Measurements.Measurement

  describe "create_measurement/1" do
    test "with valid telegram creates a measurement" do
      timestamp = DateTime.utc_now()

      telegram = %DSMR.Telegram{
        data: [
          %DSMR.Telegram.COSEM{
            obis: %{code: "0-0:1.0.0"},
            values: [%DSMR.Telegram.Value{value: timestamp}]
          }
        ]
      }

      assert {:ok, %Measurement{} = measurement} = Measurements.create_measurement(telegram)
      assert measurement.measured_at == timestamp
    end
  end

  describe "broadcast_measurement/1" do
    test "notifies subscribers of new measurements" do
      Measurements.subscribe()

      measurement = %Measurement{}
      Measurements.broadcast_measurement(measurement)

      assert_received {:measurement, ^measurement}
    end
  end
end
