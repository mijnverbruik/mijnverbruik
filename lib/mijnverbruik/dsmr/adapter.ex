defmodule Mijnverbruik.DSMR.Adapter do
  @moduledoc false

  @callback start_link(pid(), keyword()) :: GenServer.on_start()
end
