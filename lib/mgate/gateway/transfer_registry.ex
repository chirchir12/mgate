defmodule Mgate.Gateway.TransferRegistry do
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__, partitions: System.schedulers_online())
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      shutdown: 10_000
    }
  end

  def lookup(transfer_id) do
    case Registry.lookup(__MODULE__, transfer_id) do
      [{transfer_pid, _}] -> {:ok, transfer_pid}
      [] -> {:error, :not_found}
    end
  end
end
