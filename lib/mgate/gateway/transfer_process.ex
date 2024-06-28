defmodule Mgate.Gateway.TransferProcess do
  use GenServer

  alias Mgate.Transfers.Transfer
  alias Mgate.Mbanking
  alias Mgate.Repo
  require Logger

  @max_poll_retries 10
  @max_create_retries 5

  # client

  def start_link(%Transfer{} = transfer) do
    GenServer.start_link(__MODULE__, transfer,
      name: {:via, Registry, {Mgate.Gateway.TransferRegistry, transfer.uuid}}
    )
  end

  def initiate_request(pid) do
    GenServer.cast(pid, :initiate_request)
  end

  # backend
  @impl true
  def init(%Transfer{} = transfer) do
    meta = %{
      max_poll_retries: @max_poll_retries,
      max_create_retries: @max_create_retries,
      create_retries: 0,
      poll_retries: 0,
      create_ref: nil
    }

    {:ok, {transfer, meta}}
  end

  @impl true
  def handle_cast(:initiate_request, state) do
    Process.send(self(), :create, [])
    {:noreply, state}
  end

  @impl true
  def handle_continue({:save_and_poll, changeset}, {_transfer, meta}) do
    transfer = Repo.update!(changeset)
    new_meta = %{meta | poll_retries: 1}
    schedule_poll(transfer, new_meta)
    {:noreply, {transfer, new_meta}}
  end

  @impl true
  def handle_info(:create, {transfer, %{create_retries: @max_create_retries} = meta}) do
    {_transfer, changeset} = update_transfer_state(transfer, %{status: "failed"})
    new_transfer = Repo.update!(changeset)
    {:stop, :normal, {new_transfer, meta}}
  end

  @impl true
  def handle_info(:create, {transfer, meta} = state) do
    with {:ok, res} <- Mbanking.create(transfer),
         {updated_transfer, changeset} <-
           update_transfer_state(transfer, %{
             status: "pending",
             response: %{initial: res},
             response_id: to_string(res["id"])
           }) do
      {:noreply, {updated_transfer, meta}, {:continue, {:save_and_poll, changeset}}}
    else
      _ ->
        retry_create(state)
    end
  end

  @impl true
  def handle_info(:poll, {transfer, %{poll_retries: @max_poll_retries} = meta}) do
    {_transfer, changeset} = update_transfer_state(transfer, %{status: "stale"})
    new_transfer = Repo.update!(changeset)
    {:stop, :normal, {new_transfer, meta}}
  end

  @impl true
  def handle_info(:poll, {transfer, meta} = state) do
    case Mbanking.get_status(transfer) do
      {:ok, res} ->
        case res["status"] do
          "completed" ->
            {_transfer, changeset} =
              update_transfer_state(transfer, %{status: "completed", response: %{final: res}})

            new_transfer = Repo.update!(changeset)
            {:stop, :normal, {new_transfer, meta}}

          "failed" ->
            {_transfer, changeset} =
              update_transfer_state(transfer, %{status: "completed", response: %{final: res}})

            new_transfer = Repo.update!(changeset)
            {:stop, :normal, {new_transfer, meta}}

          _ ->
            retry_poll(state)
        end

      {:error, _res} ->
        retry_poll(state)
    end
  end

  @impl true
  def terminate(:normal, {%Transfer{uuid: ref_id}, _meta}) do
    Logger.debug("TERMINATING WORKER - #{ref_id}")
  end

  @impl true
  def terminate(_reason, {%Transfer{uuid: ref_id}, _meta}) do
    Logger.debug("BAD TERMINATION SIGNAL - WORKER - #{ref_id}")
  end

  defp retry_poll({transfer, meta}) do
    new_meta = %{meta | poll_retries: meta.poll_retries + 1}
    schedule_poll(transfer, new_meta)
    {:noreply, {transfer, new_meta}}
  end

  defp retry_create({transfer, meta}) do
    new_meta = %{meta | create_retries: meta.create_retries + 1}
    timer_ref = schedule_create(transfer, new_meta)
    new_meta = %{new_meta | create_ref: timer_ref}
    {:noreply, {transfer, new_meta}}
  end

  defp schedule_poll(transfer, meta) do
    in_mill = 2_000 * meta.poll_retries

    Logger.info(
      "POLL JOB FOR #{transfer.uuid}. RETRY COUNT: #{meta.poll_retries} after #{in_mill} ms "
    )

    Process.send_after(self(), :poll, in_mill)
  end

  defp schedule_create(transfer, meta) do
    in_mill = 2_000 * meta.create_retries

    Logger.info(
      "CREATE JOB FOR #{transfer.uuid}. RETRY COUNT: #{meta.create_retries} after #{in_mill} ms "
    )

    Process.send_after(self(), :create, in_mill)
  end

  defp update_transfer_state(transfer, attrs) do
    transfer
    |> Transfer.changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        updated_transfer = Ecto.Changeset.apply_changes(changeset)
        {updated_transfer, changeset}

      error_changeset ->
        {:error, error_changeset}
    end
  end


end
