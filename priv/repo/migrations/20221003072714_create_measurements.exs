defmodule Mijnverbruik.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements, primary_key: false) do
      add :equipment_id, :string
      add :electricity_delivered_1, :numeric, precision: 9, scale: 3
      add :electricity_delivered_2, :numeric, precision: 9, scale: 3
      add :electricity_returned_1, :numeric, precision: 9, scale: 3
      add :electricity_returned_2, :numeric, precision: 9, scale: 3
      add :electricity_currently_delivered, :numeric, precision: 9, scale: 3, null: false
      add :electricity_currently_returned, :numeric, precision: 9, scale: 3, null: false
      add :phase_currently_delivered_l1, :numeric, precision: 9, scale: 3
      add :phase_currently_delivered_l2, :numeric, precision: 9, scale: 3
      add :phase_currently_delivered_l3, :numeric, precision: 9, scale: 3
      add :phase_currently_returned_l1, :numeric, precision: 9, scale: 3
      add :phase_currently_returned_l2, :numeric, precision: 9, scale: 3
      add :phase_currently_returned_l3, :numeric, precision: 9, scale: 3
      add :phase_power_l1, :integer
      add :phase_power_l2, :integer
      add :phase_power_l3, :integer
      add :phase_voltage_l1, :numeric, precision: 4, scale: 1
      add :phase_voltage_l2, :numeric, precision: 4, scale: 1
      add :phase_voltage_l3, :numeric, precision: 4, scale: 1
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

    create index(:measurements, [:measured_at])
  end
end
