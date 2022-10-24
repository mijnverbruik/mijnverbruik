defmodule MijnverbruikWeb.DashboardLiveTest do
  use MijnverbruikWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mijnverbruik.MeasurementsFixtures

  describe "index" do
    test "updates realtime measurement", %{conn: conn} do
      measurement_fixture(%{
        electricity_currently_delivered: Decimal.new("0.697"),
        electricity_currently_returned: Decimal.new("0.432")
      })

      {:ok, view, _} = live(conn, Routes.dashboard_path(conn, :index))

      assert view
             |> element("#electricity-panel h2")
             |> render() =~ "Electricity"

      assert view
             |> element("#electricity-realtime-value")
             |> render() =~ "265"

      measurement =
        measurement_fixture(%{
          electricity_currently_delivered: Decimal.new("0.789"),
          electricity_currently_returned: Decimal.new("0.321")
        })

      send(view.pid, {:measurement, measurement})

      assert view
             |> element("#electricity-realtime-value")
             |> render() =~ "468"
    end
  end
end
