defmodule Mijnverbruik.Measurements do
  @moduledoc false

  import Ecto.Query

  alias Mijnverbruik.Measurements.{Measurement, Summary}
  alias Mijnverbruik.Repo

  # Summaries

  def get_summary_for_60m(period) do
    Summary.per_60m()
    |> get_summary_for_period(period)
  end

  def get_summary_for_24h(period) do
    Summary.per_24h()
    |> get_summary_for_period(period)
  end

  defp get_summary_for_period(query, period) do
    from(
      q in query,
      select_merge: %{
        mbus_channel_1_delivered:
          q.mbus_channel_1_delivered -
            over(lead(q.mbus_channel_1_delivered),
              order_by: [desc: q.mbus_channel_1_measured_at]
            ),
        mbus_channel_2_delivered:
          q.mbus_channel_2_delivered -
            over(lead(q.mbus_channel_2_delivered),
              order_by: [desc: q.mbus_channel_2_measured_at]
            ),
        mbus_channel_3_delivered:
          q.mbus_channel_3_delivered -
            over(lead(q.mbus_channel_3_delivered),
              order_by: [desc: q.mbus_channel_3_measured_at]
            ),
        mbus_channel_4_delivered:
          q.mbus_channel_4_delivered -
            over(lead(q.mbus_channel_4_delivered),
              order_by: [desc: q.mbus_channel_4_measured_at]
            )
      },
      where: q.measured_at <= ^period,
      order_by: [desc: q.measured_at],
      limit: 1
    )
    |> Repo.one()
  end

  @spec summarize_last_hour() :: :ok
  def summarize_last_hour() do
    Summary.summarize_last_hour_query() |> upsert_last_period("measurements_per_60m")
  end

  @spec summarize_last_day() :: :ok
  def summarize_last_day() do
    Summary.summarize_last_day_query() |> upsert_last_period("measurements_per_24h")
  end

  defp upsert_last_period(query, source) do
    {_, nil} =
      Repo.insert_all(
        {source, Summary},
        query,
        # When the summary for a given period already exists, we just replace it
        # with a new summary. This works because the query is using a "window" of one
        # or more rows to resummarize a given period.
        on_conflict: :replace_all,
        conflict_target: [:equipment_id, :measured_at]
      )

    :ok
  end

  # Measurements

  @spec get_latest_measurement() :: Measurement.t() | nil
  def get_latest_measurement() do
    from(Measurement, order_by: [desc: :measured_at], limit: 1)
    |> Repo.one()
  end

  def create_measurement(%DSMR.Telegram{} = telegram) do
    telegram
    |> measurement_attrs()
    |> create_measurement()
  end

  def create_measurement(attrs) do
    # TODO: Attach equipment based on identifiers?
    %Measurement{}
    |> Measurement.changeset(attrs)
    |> Repo.insert()
  end

  defp measurement_attrs(%DSMR.Telegram{} = telegram) do
    {mbus, cosem} = Enum.split_with(telegram.data, &mbus?/1)

    cosem = Enum.reduce(cosem, %{}, &measurement_attrs/2)

    mbus
    |> Enum.map(&measurement_attrs/1)
    # Merge MBus values into resolved attributes from COSEM struct.
    |> Enum.reduce(cosem, &Map.merge/2)
  end

  defp measurement_attrs(%DSMR.Telegram.MBus{} = mbus) do
    Enum.reduce(mbus.data, %{}, &measurement_attrs/2)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "0-0:96.1.1"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :equipment_id, value.raw)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "0-0:1.0.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :measured_at, DateTime.shift_zone!(value.value, "UTC"))
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:1.8.1"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_delivered_1, value.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:1.8.2"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_delivered_2, value.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:2.8.1"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_returned_1, value.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:2.8.2"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_returned_2, value.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:1.7.0"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_currently_delivered, value.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{obis: %{code: "1-0:2.7.0"}, values: [value]}, attrs) do
    Map.put(attrs, :electricity_currently_returned, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:21.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_delivered_l1, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:41.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_delivered_l2, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:61.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_delivered_l3, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:22.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_returned_l1, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:42.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_returned_l2, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:62.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_currently_returned_l3, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:31.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_power_l1, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:32.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_voltage_l1, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:51.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_power_l3, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:52.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_voltage_l2, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:71.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_power_l3, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{code: "1-0:72.7.0"}, values: [value]},
         attrs
       ) do
    Map.put(attrs, :phase_voltage_l3, value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{obis: %{tags: [mbus: :device_type]} = obis, values: [value]},
         attrs
       ) do
    Map.put(attrs, :"mbus_channel_#{obis.channel}_device_type", value.value)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{
           obis: %{tags: [mbus: :equipment_identifier]} = obis,
           values: [value]
         },
         attrs
       ) do
    Map.put(attrs, :"mbus_channel_#{obis.channel}_equipment_id", value.raw)
  end

  defp measurement_attrs(
         %DSMR.Telegram.COSEM{
           obis: %{tags: [mbus: :measurement]} = obis,
           values: [capture, reading]
         },
         attrs
       ) do
    attrs
    |> Map.put(
      :"mbus_channel_#{obis.channel}_measured_at",
      DateTime.shift_zone!(capture.value, "UTC")
    )
    |> Map.put(:"mbus_channel_#{obis.channel}_delivered", reading.value)
  end

  defp measurement_attrs(%DSMR.Telegram.COSEM{}, attrs), do: attrs

  defp mbus?(%DSMR.Telegram.MBus{}), do: true
  defp mbus?(_), do: false

  @spec broadcast_measurement(Measurement.t()) :: :ok
  def broadcast_measurement(measurement) do
    Phoenix.PubSub.broadcast(Mijnverbruik.PubSub, "measurements", {:measurement, measurement})
  end

  @doc """
  Subscribes to updates in measurements.

  ## Messages

    * `{:measurement, measurement}`

  """
  @spec subscribe() :: :ok | {:error, term()}
  def subscribe() do
    Phoenix.PubSub.subscribe(Mijnverbruik.PubSub, "measurements")
  end

  @doc """
  Unsubscribes from `subscribe/1`.
  """
  @spec unsubscribe() :: :ok
  def unsubscribe() do
    Phoenix.PubSub.unsubscribe(Mijnverbruik.PubSub, "measurements")
  end
end
