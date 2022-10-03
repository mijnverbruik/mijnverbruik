defmodule Mijnverbruik.MeasurementsFixtures do
  alias Mijnverbruik.Measurements.Measurement
  alias Mijnverbruik.Repo

  def measurement_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        measured_at: DateTime.utc_now()
      })

    {:ok, measurement} =
      %Measurement{}
      |> Measurement.changeset(attrs)
      |> Repo.insert()

    measurement
  end
end
