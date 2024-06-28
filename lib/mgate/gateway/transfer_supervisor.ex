defmodule Mgate.Gateway.TransferSupervisor do
  use DynamicSupervisor
  alias Mgate.Gateway.TransferProcess
  alias Mgate.Transfers.Transfer

  def start_link(options) do
    DynamicSupervisor.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(_options) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def init_transfer_process(%Transfer{} = transfer) do
    child_spec = %{
      id: TransferProcess,
      start: {TransferProcess, :start_link, [transfer]},
      restart: :transient
    }

    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, child_spec)
    {:ok, pid}
  end
end
