defmodule MgateWeb.TransferControllerTest do
  use MgateWeb.ConnCase

  import Mgate.TransfersFixtures

  alias Mgate.Transfers.Transfer

  @create_attrs %{
    source: 42,
    destination: 42,
    uuid: "some uuid",
    transfer_type: "some transfer_type"
  }
  @update_attrs %{
    source: 43,
    destination: 43,
    uuid: "some updated uuid",
    transfer_type: "some updated transfer_type"
  }
  @invalid_attrs %{source: nil, destination: nil, uuid: nil, transfer_type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all transfers", %{conn: conn} do
      conn = get(conn, ~p"/api/transfers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create transfer" do
    test "renders transfer when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/transfers", transfer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/transfers/#{id}")

      assert %{
               "id" => ^id,
               "destination" => 42,
               "source" => 42,
               "transfer_type" => "some transfer_type",
               "uuid" => "some uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/transfers", transfer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update transfer" do
    setup [:create_transfer]

    test "renders transfer when data is valid", %{
      conn: conn,
      transfer: %Transfer{id: id} = transfer
    } do
      conn = put(conn, ~p"/api/transfers/#{transfer}", transfer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/transfers/#{id}")

      assert %{
               "id" => ^id,
               "destination" => 43,
               "source" => 43,
               "transfer_type" => "some updated transfer_type",
               "uuid" => "some updated uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, transfer: transfer} do
      conn = put(conn, ~p"/api/transfers/#{transfer}", transfer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete transfer" do
    setup [:create_transfer]

    test "deletes chosen transfer", %{conn: conn, transfer: transfer} do
      conn = delete(conn, ~p"/api/transfers/#{transfer}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/transfers/#{transfer}")
      end
    end
  end

  defp create_transfer(_) do
    transfer = transfer_fixture()
    %{transfer: transfer}
  end
end
