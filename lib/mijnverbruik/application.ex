defmodule Mijnverbruik.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Mijnverbruik.Repo,
      # Start the DSMR meter
      meter_spec(),
      # Start the Telemetry supervisor
      MijnverbruikWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mijnverbruik.PubSub},
      # Start the Endpoint (http/https)
      MijnverbruikWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mijnverbruik.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp meter_spec() do
    name = Mijnverbruik.DSMR.Meter

    if Mijnverbruik.Config.meter_enabled?() do
      {name, host: "10.10.0.4", port: 23}
      # {name, tty: "/dev/dummy2"}
    else
      %{id: name, start: {Function, :identity, [:ignore]}}
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MijnverbruikWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
