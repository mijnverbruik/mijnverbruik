defmodule Mijnverbruik.Measurements.Measurement do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          equipment_id: String.t(),
          electricity_delivered_1: Decimal.t() | nil,
          electricity_delivered_2: Decimal.t() | nil,
          electricity_returned_1: Decimal.t() | nil,
          electricity_returned_2: Decimal.t() | nil,
          electricity_currently_delivered: Decimal.t(),
          electricity_currently_returned: Decimal.t(),
          phase_currently_delivered_l1: Decimal.t() | nil,
          phase_currently_delivered_l2: Decimal.t() | nil,
          phase_currently_delivered_l3: Decimal.t() | nil,
          phase_currently_returned_l1: Decimal.t() | nil,
          phase_currently_returned_l2: Decimal.t() | nil,
          phase_currently_returned_l3: Decimal.t() | nil,
          phase_power_l1: integer() | nil,
          phase_power_l2: integer() | nil,
          phase_power_l3: integer() | nil,
          phase_voltage_l1: Decimal.t() | nil,
          phase_voltage_l2: Decimal.t() | nil,
          phase_voltage_l3: Decimal.t() | nil,
          mbus_channel_1_equipment_id: String.t() | nil,
          mbus_channel_1_device_type: String.t() | nil,
          mbus_channel_1_measured_at: Datetime.t() | nil,
          mbus_channel_1_delivered: Decimal.t() | nil,
          mbus_channel_2_equipment_id: String.t() | nil,
          mbus_channel_2_device_type: String.t() | nil,
          mbus_channel_2_measured_at: Datetime.t() | nil,
          mbus_channel_2_delivered: Decimal.t() | nil,
          mbus_channel_3_equipment_id: String.t() | nil,
          mbus_channel_3_device_type: String.t() | nil,
          mbus_channel_3_measured_at: Datetime.t() | nil,
          mbus_channel_3_delivered: Decimal.t() | nil,
          mbus_channel_4_equipment_id: String.t() | nil,
          mbus_channel_4_device_type: String.t() | nil,
          mbus_channel_4_measured_at: Datetime.t() | nil,
          mbus_channel_4_delivered: Decimal.t() | nil,
          measured_at: Datetime.t()
        }

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

    for channel <- 1..4 do
      field :"mbus_channel_#{channel}_equipment_id", :string
      field :"mbus_channel_#{channel}_device_type", :integer
      field :"mbus_channel_#{channel}_measured_at", :utc_datetime_usec
      field :"mbus_channel_#{channel}_delivered", :decimal
    end

    field :measured_at, :utc_datetime_usec
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
