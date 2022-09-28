defmodule Mijnverbruik.DSMR.SerialTest do
  use ExUnit.Case, async: true

  alias Mijnverbruik.DSMR.Serial

  describe "handle_info/2" do
    setup do
      %{state: %{telegram: "", parent_pid: self()}}
    end

    test "buffers partial telegram onto new state", %{state: state} do
      state = %{state | telegram: "foo\r\n"}
      new_state = %{state | telegram: "foo\r\nbar"}

      assert {:noreply, ^new_state} =
               Serial.handle_info({:circuits_uart, "/dev/dummy", "bar"}, state)
    end

    test "sends telegram to subscriber when receiving terminator", %{state: state} do
      state = %{state | telegram: "foo\r\n"}
      new_state = %{state | telegram: ""}

      assert {:noreply, ^new_state} =
               Serial.handle_info({:circuits_uart, "/dev/dummy", "!bar"}, state)

      assert_receive {:telegram, "foo\r\n!bar"}
    end
  end
end
