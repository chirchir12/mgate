defmodule Mgate.TransfersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mgate.Transfers` context.
  """

  @doc """
  Generate a unique transfer uuid.
  """
  def unique_transfer_uuid, do: "some uuid#{System.unique_integer([:positive])}"

  @doc """
  Generate a transfer.
  """
  def transfer_fixture(attrs \\ %{}) do
    {:ok, transfer} =
      attrs
      |> Enum.into(%{
        destination: 42,
        source: 42,
        transfer_type: "some transfer_type",
        uuid: unique_transfer_uuid()
      })
      |> Mgate.Transfers.create_transfer()

    transfer
  end
end
