defmodule Ammo.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :map
      add :caption, :map
      add :sha, :string
      add :latlon, :geometry
      add :taken_at, :utc_datetime

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:photos, [:user_id])
    create unique_index(:photos, [:sha])
  end
end
