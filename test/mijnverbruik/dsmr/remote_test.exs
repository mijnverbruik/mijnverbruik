defmodule Mijnverbruik.DSMR.RemoteTest do
  use ExUnit.Case, async: true

  alias Mijnverbruik.DSMR.Remote

  describe "handle_info/2" do
    setup do
      %{state: %{lines: "", parent_pid: self()}}
    end

    test "buffers partial telegram onto new state", %{state: state} do
      state = %{state | lines: "foo\r\n"}
      new_state = %{state | lines: "foo\r\nbar\r\n"}

      assert {:noreply, ^new_state} = Remote.handle_info({:recv_line, "bar\r\n"}, state)
    end

    test "sends telegram to subscriber when receiving terminator", %{state: state} do
      state = %{state | lines: "foo\r\n"}
      new_state = %{state | lines: ""}

      assert {:noreply, ^new_state} = Remote.handle_info({:recv_line, "!bar\r\n"}, state)
      assert_receive {:telegram, "foo\r\n!bar\r\n"}
    end
  end
end
