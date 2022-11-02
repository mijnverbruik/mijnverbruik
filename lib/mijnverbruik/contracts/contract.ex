defmodule Mijnverbruik.Contracts.Contract do
  use Ecto.Schema

  schema "contracts" do
    field :name, :string
    field :date_start, :date
    field :date_end, :date
    field :electricity_delivered_1, :decimal
    field :electricity_delivered_2, :decimal
    field :electricity_returned_1, :decimal
    field :electricity_returned_2, :decimal
    field :mbus_channel_1_delivered, :decimal
    field :mbus_channel_2_delivered, :decimal
    field :mbus_channel_3_delivered, :decimal
    field :mbus_channel_4_delivered, :decimal
    field :fixed_costs, :decimal

    timestamps()
  end
end
