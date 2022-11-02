defmodule Mijnverbruik.Contracts do
  alias Mijnverbruik.Contracts.Contract
  alias Mijnverbruik.Repo

  ## Contracts

  def get_contract(id), do: Repo.get(Contract, id)
end
