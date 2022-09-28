defmodule Mijnverbruik.Config do
  @moduledoc false

  @doc """
  Returns whether the meter feature is enabled.
  """
  @spec meter_enabled?() :: boolean()
  def meter_enabled?() do
    Application.get_env(:mijnverbruik, :meter_enabled, true)
  end
end
