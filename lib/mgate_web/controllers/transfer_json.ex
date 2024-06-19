defmodule MgateWeb.TransferJSON do
  alias Mgate.Transfers.Transfer

  @doc """
  Renders a list of transfers.
  """
  def index(%{transfers: transfers}) do
    %{data: for(transfer <- transfers, do: data(transfer))}
  end

  @doc """
  Renders a single transfer.
  """
  def show(%{transfer: transfer}) do
    %{data: data(transfer)}
  end

  defp data(%Transfer{} = transfer) do
    %{
      id: transfer.id,
      uuid: transfer.uuid,
      source: transfer.source,
      destination: transfer.destination,
      transfer_type: transfer.transfer_type,
      user_id: transfer.user_id,
      amount: transfer.amount,
      status: transfer.status
    }
  end
end
