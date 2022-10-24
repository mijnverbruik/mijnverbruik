defmodule Mijnverbruik.DSMR.RemoteTest do
  use ExUnit.Case, async: true

  alias Mijnverbruik.DSMR.Remote

  describe "handle_info/2" do
    setup do
      %{state: %{frames: "", parent_pid: self()}}
    end

    test "buffers partial telegram onto new state", %{state: state} do
      state = %{state | frames: "foo\r\n"}
      new_state = %{state | frames: "foo\r\nbar"}

      assert {:noreply, ^new_state} = Remote.handle_info({:tcp, nil, "bar"}, state)
    end

    test "sends telegram to subscriber when receiving terminator", %{state: state} do
      state = %{state | frames: "foo\r\n"}
      new_state = %{state | frames: ""}

      assert {:noreply, ^new_state} = Remote.handle_info({:tcp, nil, "!bar\r\n"}, state)
      assert_receive {:telegram, "foo\r\n!bar\r\n"}
    end
  end
end
