defmodule MgateWeb.TransferController do
  use MgateWeb, :controller

  alias Mgate.Transfers
  alias Mgate.Transfers.Transfer
  alias Mgate.Gateway

  action_fallback MgateWeb.FallbackController

  def create(conn, %{"transfer" => transfer_params}) do
    with {:ok, %Transfer{} = transfer} <- Transfers.create_transfer(transfer_params),
         {:ok, :dispatched} <- Gateway.dispatch(transfer) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/transfers/#{transfer}")
      |> render(:show, transfer: transfer)
    end
  end

  def show(conn, %{"id" => id}) do
      with transfer <- Transfers.get_transfer!(id) do
        render(conn, :show, transfer: transfer)
      end
  end

  def update(conn, %{"id" => id, "transfer" => transfer_params}) do
    transfer = Transfers.get_transfer!(id)

    with {:ok, %Transfer{} = transfer} <- Transfers.update_transfer(transfer, transfer_params) do
      render(conn, :show, transfer: transfer)
    end
  end
end
