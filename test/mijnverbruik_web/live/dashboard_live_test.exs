defmodule MijnverbruikWeb.DashboardLiveTest do
  use MijnverbruikWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mijnverbruik.MeasurementsFixtures

  describe "index" do
    test "updates latest measurement", %{conn: conn} do
      measurement_fixture(%{
        electricity_currently_delivered: Decimal.new("0.697"),
        electricity_currently_returned: Decimal.new("0.432")
      })

      {:ok, view, html} = live(conn, Routes.dashboard_path(conn, :index))
      assert html =~ "<h1>Dashboard</h1>"
      assert html =~ "0.697 W"
      assert html =~ "0.432 W"

      measurement =
        measurement_fixture(%{
          electricity_currently_delivered: Decimal.new("0.789"),
          electricity_currently_returned: Decimal.new("0.321")
        })

      send(view.pid, {:measurement, measurement})

      html = render(view)
      assert html =~ "0.789 W"
      assert html =~ "0.321 W"
    end
  end
end
