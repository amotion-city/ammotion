defmodule Ammo.Repo.Migrations.CreateUserAccounts do
  use Ecto.Migration

  def change do
    create table(:user_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :raw_info, :map

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:user_accounts, [:user_id])
  end
end
