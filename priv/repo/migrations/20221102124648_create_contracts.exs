defmodule Mijnverbruik.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts) do
      add :name, :string, null: false
      add :date_start, :date
      add :date_end, :date
      add :electricity_delivered_1, :numeric, precision: 11, scale: 5
      add :electricity_delivered_2, :numeric, precision: 11, scale: 5
      add :electricity_returned_1, :numeric, precision: 11, scale: 5
      add :electricity_returned_2, :numeric, precision: 11, scale: 5
      add :mbus_channel_1_delivered, :numeric, precision: 11, scale: 5
      add :mbus_channel_2_delivered, :numeric, precision: 11, scale: 5
      add :mbus_channel_3_delivered, :numeric, precision: 11, scale: 5
      add :mbus_channel_4_delivered, :numeric, precision: 11, scale: 5
      add :fixed_costs, :numeric, precision: 11, scale: 5
      timestamps()
    end
  end
end
