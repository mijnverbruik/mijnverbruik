defmodule Mijnverbruik.Repo.Migrations.CreateMeasurementsSummaries do
  use Ecto.Migration

  def change do
    create_measurement_summary_table("60m")
    create_measurement_summary_table("24h")
  end

  defp create_measurement_summary_table(period) do
    table_name = "measurements_per_#{period}"

    create table(table_name, primary_key: false) do
      add :equipment_id, :string
      add :electricity_delivered_1, :numeric, precision: 9, scale: 3
      add :electricity_delivered_2, :numeric, precision: 9, scale: 3
      add :electricity_returned_1, :numeric, precision: 9, scale: 3
      add :electricity_returned_2, :numeric, precision: 9, scale: 3
      add :mbus_channel_1_equipment_id, :string
      add :mbus_channel_1_device_type, :integer
      add :mbus_channel_1_measured_at, :utc_datetime_usec
      add :mbus_channel_1_delivered, :numeric, precision: 9, scale: 3
      add :mbus_channel_2_equipment_id, :string
      add :mbus_channel_2_device_type, :integer
      add :mbus_channel_2_measured_at, :utc_datetime_usec
      add :mbus_channel_2_delivered, :numeric, precision: 9, scale: 3
      add :mbus_channel_3_equipment_id, :string
      add :mbus_channel_3_device_type, :integer
      add :mbus_channel_3_measured_at, :utc_datetime_usec
      add :mbus_channel_3_delivered, :numeric, precision: 9, scale: 3
      add :mbus_channel_4_equipment_id, :string
      add :mbus_channel_4_device_type, :integer
      add :mbus_channel_4_measured_at, :utc_datetime_usec
      add :mbus_channel_4_delivered, :numeric, precision: 9, scale: 3
      add :measured_at, :utc_datetime_usec, null: false
    end

    create unique_index(table_name, [:equipment_id, :measured_at])
  end
end
