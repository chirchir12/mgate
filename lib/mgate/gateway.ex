defmodule Mgate.Gateway do
  alias Mgate.Transfers.Transfer
  alias Mgate.Gateway.TransferSupervisor
  alias Mgate.Gateway.TransferRegistry
  alias Mgate.Gateway.TransferProcess

  def dispatch(%Transfer{uuid: uuid} = transfer) do
    case TransferRegistry.lookup(uuid) do
      {:ok, _pid} ->
        {:error, :transaction_in_progress}

      {:error, :not_found} ->
        {:ok, pid} = TransferSupervisor.init_transfer_process(transfer)
        :ok = TransferProcess.initiate_request(pid)
        {:ok, :dispatched}
    end
  end
end
