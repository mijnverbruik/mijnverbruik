defmodule Mijnverbruik.Measurements.Summary do
  use Ecto.Schema

  import Ecto.Query

  @type t :: %__MODULE__{
          equipment_id: String.t(),
          electricity_delivered_1: Decimal.t(),
          electricity_delivered_2: Decimal.t(),
          electricity_returned_1: Decimal.t(),
          electricity_returned_2: Decimal.t(),
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

  schema "summaries" do
    field :equipment_id, :string

    field :electricity_delivered_1, :decimal, default: 0
    field :electricity_delivered_2, :decimal, default: 0
    field :electricity_returned_1, :decimal, default: 0
    field :electricity_returned_2, :decimal, default: 0

    for channel <- 1..4 do
      field :"mbus_channel_#{channel}_equipment_id", :string
      field :"mbus_channel_#{channel}_device_type", :integer
      field :"mbus_channel_#{channel}_measured_at", :utc_datetime_usec
      field :"mbus_channel_#{channel}_delivered", :decimal
    end

    field :measured_at, :utc_datetime_usec
  end

  def per_60m(),
    do: from(s in {"measurements_per_60m", __MODULE__})

  def per_24h(),
    do: from(s in {"measurements_per_24h", __MODULE__})

  def summarize_last_hour_query(), do: summarize_last_period_query("%Y-%m-%d %H:00:00.000")
  def summarize_last_day_query(), do: summarize_last_period_query("%Y-%m-%d 00:00:00.000")

  def summarize_last_period_query(period) do
    from m in Mijnverbruik.Measurements.Measurement,
      select: %{
        equipment_id: m.equipment_id,
        electricity_delivered_1:
          over(first_value(m.electricity_delivered_1), :bucket) -
            over(last_value(m.electricity_delivered_1), :bucket),
        electricity_delivered_2:
          over(first_value(m.electricity_delivered_2), :bucket) -
            over(last_value(m.electricity_delivered_2), :bucket),
        electricity_returned_1:
          over(first_value(m.electricity_returned_1), :bucket) -
            over(last_value(m.electricity_returned_1), :bucket),
        electricity_returned_2:
          over(first_value(m.electricity_returned_2), :bucket) -
            over(last_value(m.electricity_returned_2), :bucket),
        mbus_channel_1_equipment_id: m.mbus_channel_1_equipment_id,
        mbus_channel_1_device_type: m.mbus_channel_1_device_type,
        mbus_channel_1_measured_at:
          type(over(first_value(m.mbus_channel_1_measured_at), :bucket), :utc_datetime_usec),
        mbus_channel_1_delivered:
          over(first_value(m.mbus_channel_1_measured_at), :bucket) -
            over(last_value(m.mbus_channel_1_measured_at), :bucket),
        mbus_channel_2_equipment_id: m.mbus_channel_2_equipment_id,
        mbus_channel_2_device_type: m.mbus_channel_2_device_type,
        mbus_channel_2_measured_at:
          type(over(first_value(m.mbus_channel_2_measured_at), :bucket), :utc_datetime_usec),
        mbus_channel_2_delivered:
          over(first_value(m.mbus_channel_2_measured_at), :bucket) -
            over(last_value(m.mbus_channel_2_measured_at), :bucket),
        mbus_channel_3_equipment_id: m.mbus_channel_3_equipment_id,
        mbus_channel_3_device_type: m.mbus_channel_3_device_type,
        mbus_channel_3_measured_at:
          type(over(first_value(m.mbus_channel_3_measured_at), :bucket), :utc_datetime_usec),
        mbus_channel_3_delivered:
          over(first_value(m.mbus_channel_3_measured_at), :bucket) -
            over(last_value(m.mbus_channel_3_measured_at), :bucket),
        mbus_channel_4_equipment_id: m.mbus_channel_4_equipment_id,
        mbus_channel_4_device_type: m.mbus_channel_4_device_type,
        mbus_channel_4_measured_at:
          type(over(first_value(m.mbus_channel_4_measured_at), :bucket), :utc_datetime_usec),
        mbus_channel_4_delivered:
          over(first_value(m.mbus_channel_4_measured_at), :bucket) -
            over(last_value(m.mbus_channel_4_measured_at), :bucket),
        measured_at: type(fragment("strftime(?, ?)", ^period, m.measured_at), :utc_datetime_usec)
      },
      where: true,
      order_by: [desc: m.measured_at],
      limit: 1,
      windows: [
        bucket: [
          partition_by: [m.equipment_id, fragment("strftime(?, ?)", ^period, m.measured_at)],
          order_by: [desc: m.measured_at],
          frame: fragment("RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING")
        ]
      ]
  end
end
