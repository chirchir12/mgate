defmodule Mgate.Mbanking do
  alias Mgate.Integrations.Mbanking
  alias Mgate.Transfers.Transfer

  def create(%Transfer{status: "created"} = transfer) do
    with {:ok, res} <- Mbanking.create(transfer, get_options!()) do
      {:ok, res}
    end
  end

  def create(_) do
    {:error, :invalid_create_status}
  end

  def get_status(%Transfer{status: "pending"} = transfer) do
    with {:ok, res} <- Mbanking.get_status(transfer, get_options!()) do
      {:ok, res}
    end
  end

  def get_status(_) do
    {:error, :invalid_pending_status}
  end

  defp get_options!() do
    option = :mgate |> Application.get_env(__MODULE__)
    option
  end
end
