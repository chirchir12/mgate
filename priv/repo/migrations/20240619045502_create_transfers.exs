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
      add :meta, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:transfers, [:uuid])
  end
end
