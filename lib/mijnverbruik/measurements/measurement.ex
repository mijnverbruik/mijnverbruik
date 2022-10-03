defmodule Mijnverbruik.Measurements.Measurement do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  schema "measurements" do
    field :equipment_id, :string

    field :electricity_delivered_1, :decimal
    field :electricity_delivered_2, :decimal
    field :electricity_returned_1, :decimal
    field :electricity_returned_2, :decimal

    field :electricity_currently_delivered, :decimal, default: 0
    field :electricity_currently_returned, :decimal, default: 0

    field :phase_currently_delivered_l1, :decimal
    field :phase_currently_delivered_l2, :decimal
    field :phase_currently_delivered_l3, :decimal
    field :phase_currently_returned_l1, :decimal
    field :phase_currently_returned_l2, :decimal
    field :phase_currently_returned_l3, :decimal

    field :phase_power_l1, :integer
    field :phase_power_l2, :integer
    field :phase_power_l3, :integer
    field :phase_voltage_l1, :decimal
    field :phase_voltage_l2, :decimal
    field :phase_voltage_l3, :decimal

    field :measured_at, :utc_datetime_usec

    for channel <- 1..4 do
      field :"mbus_channel_#{channel}_equipment_id", :string
      field :"mbus_channel_#{channel}_device_type", :integer
      field :"mbus_channel_#{channel}_measured_at", :utc_datetime_usec
      field :"mbus_channel_#{channel}_delivered", :decimal
    end
  end

  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [
      :equipment_id,
      :electricity_delivered_1,
      :electricity_delivered_2,
      :electricity_returned_1,
      :electricity_returned_2,
      :electricity_currently_delivered,
      :electricity_currently_returned,
      :phase_currently_delivered_l1,
      :phase_currently_delivered_l2,
      :phase_currently_delivered_l3,
      :phase_currently_returned_l1,
      :phase_currently_returned_l2,
      :phase_currently_returned_l3,
      :phase_power_l1,
      :phase_power_l2,
      :phase_power_l3,
      :phase_voltage_l1,
      :phase_voltage_l2,
      :phase_voltage_l3,
      :mbus_channel_1_equipment_id,
      :mbus_channel_1_device_type,
      :mbus_channel_1_measured_at,
      :mbus_channel_1_delivered,
      :mbus_channel_2_equipment_id,
      :mbus_channel_2_device_type,
      :mbus_channel_2_measured_at,
      :mbus_channel_2_delivered,
      :mbus_channel_3_equipment_id,
      :mbus_channel_3_device_type,
      :mbus_channel_3_measured_at,
      :mbus_channel_3_delivered,
      :mbus_channel_4_equipment_id,
      :mbus_channel_4_device_type,
      :mbus_channel_4_measured_at,
      :mbus_channel_4_delivered,
      :measured_at
    ])
  end
end
