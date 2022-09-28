defmodule Mijnverbruik.DSMR.RemoteTest do
  use ExUnit.Case, async: true

  alias Mijnverbruik.DSMR.Remote

  describe "handle_info/2" do
    setup do
      %{state: %{telegram: "", parent_pid: self()}}
    end

    test "buffers partial telegram onto new state", %{state: state} do
      state = %{state | telegram: "foo\r\n"}
      new_state = %{state | telegram: "foo\r\nbar"}

      assert {:noreply, ^new_state} = Remote.handle_info({:tcp, nil, "bar"}, state)
    end

    test "sends telegram to subscriber when receiving terminator", %{state: state} do
      state = %{state | telegram: "foo\r\n"}
      new_state = %{state | telegram: ""}

      assert {:noreply, ^new_state} = Remote.handle_info({:tcp, nil, "!bar"}, state)
      assert_receive {:telegram, "foo\r\n!bar"}
    end
  end
end
