defmodule Mgate.Repo.Migrations.CreateTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :uuid, :uuid, null: false
      add :user_id, :uuid, null: false
      add :source, :integer, null: false
      add :destination, :integer, null: false
      add :transfer_type, :string, null: false
      add :amount, :decimal, null: false
      add :status, :string, null: false
      add :meta, :map
      add :response, :map
      add :response_id, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create index(:transfers, [:response_id])

    create unique_index(:transfers, [:uuid])
  end
end
