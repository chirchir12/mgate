defmodule MgateWeb.TransferController do
  use MgateWeb, :controller

  alias Mgate.Transfers
  alias Mgate.Transfers.Transfer
  alias Mgate.Mbanking

  action_fallback MgateWeb.FallbackController

  def create(conn, %{"transfer" => transfer_params}) do
    with {:ok, %Transfer{} = transfer} <- Transfers.create_transfer(transfer_params),
         {:ok, res} <- Mbanking.create(transfer),
         {:ok, updated_transfer} <-
           Transfers.update_transfer(transfer, %{
             status: "pending",
             response_id: to_string(res["id"]),
             response: %{initial: res}
           }) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/transfers/#{transfer}")
      |> render(:show, transfer: updated_transfer)
    end
  end

  def show(conn, %{"id" => id}) do
    transfer = with transfer <- Transfers.get_transfer!(id) do
      case is_pending(transfer) do
        false -> transfer
        true -> check_and_update(transfer)
      end
    end
    render(conn, :show, transfer: transfer)
  end

  def update(conn, %{"id" => id, "transfer" => transfer_params}) do
    transfer = Transfers.get_transfer!(id)

    with {:ok, %Transfer{} = transfer} <- Transfers.update_transfer(transfer, transfer_params) do
      render(conn, :show, transfer: transfer)
    end
  end

  defp check_and_update(%Transfer{} = transfer) do
    with {:ok, res} <- Mbanking.get_status(transfer) do
      case res["status"] do
        "completed" -> handle_transfer_update(transfer, res, :completed)
        "pending" -> transfer
        "failed" -> handle_transfer_update(transfer, res, :failed)
      end
    end
  end

  defp handle_transfer_update(transfer, res, :completed) do
    with {:ok, transfer} <- Transfers.update_transfer(transfer, %{
      status: "completed",
      response: %{final: res}
    })  do
      transfer
    end
  end

  defp handle_transfer_update(transfer, res, :failed) do
    with {:ok, transfer} <- Transfers.update_transfer(transfer, %{
      status: "failed",
      response: %{final: res}
    })  do
      transfer
    end
  end

  defp is_pending(%Transfer{status: "pending"}), do: true
  defp is_pending(_), do: false
end
