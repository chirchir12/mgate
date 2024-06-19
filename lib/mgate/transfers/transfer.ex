defmodule Mgate.Transfers.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_status ["created", "pending", "completed", "failed"]

  @permitted [:source, :destination, :uuid, :user_id, :transfer_type, :amount, :meta, :status, :response, :response_id]

  @required [:source, :destination, :uuid, :user_id, :transfer_type, :amount]

  schema "transfers" do
    field :source, :integer
    field :destination, :integer
    field :uuid, Ecto.UUID
    field :transfer_type, :string
    field :amount, :decimal
    field :status, :string
    field :user_id, Ecto.UUID
    field :meta, :map
    # third parti response
    field :response, :map
    # third parties can mess around
    field :response_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:uuid)
    |> put_status()
    |> validate_status()
  end

  defp put_status(%Ecto.Changeset{valid?: true} = changeset) do
    status = changeset |> get_change(:status)

    case status do
      nil -> changeset |> put_change(:status, "created")
      _ -> changeset
    end
  end

  defp put_status(changeset), do: changeset

  defp validate_status(changeset) do
    status = changeset |> get_change(:status)

    case status in @allowed_status do
      true ->
        changeset

      false ->
        changeset
        |> add_error(
          :status,
          "invalid status #{status}, allowed status are #{Enum.join(@allowed_status, ", ")}"
        )
    end
  end
end
