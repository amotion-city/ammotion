defmodule Ammo.Repo.Migrations.CreatePhotosInAlbums do
  use Ecto.Migration

  def change do
    create table(:photos_in_albums, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :photo_id, references(:photos, on_delete: :nothing, type: :binary_id)
      add :album_id, references(:albums, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create unique_index(:photos_in_albums, ~w|photo_id album_id|a)
  end
end
