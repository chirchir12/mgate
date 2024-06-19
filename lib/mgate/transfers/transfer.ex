defmodule Mgate.Transfers.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted [:source, :destination, :uuid, :user_id, :transfer_type, :amount, :meta]

  @required [:source, :destination, :uuid, :user_id, :transfer_type, :amount]

  schema "transfers" do
    field :source, :integer
    field :destination, :integer
    field :uuid, Ecto.UUID
    field :transfer_type, :string
    field :amount, :decimal
    field :user_id, Ecto.UUID
    field :meta, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:uuid)
  end
end
