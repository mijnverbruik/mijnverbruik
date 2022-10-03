defmodule Mijnverbruik.MeasurementsTest do
  use Mijnverbruik.DataCase, async: true

  alias Mijnverbruik.Measurements
  alias Mijnverbruik.Measurements.Measurement

  describe "measurements" do
    test "create_measurement/1 with valid telegram creates a measurement" do
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
end
