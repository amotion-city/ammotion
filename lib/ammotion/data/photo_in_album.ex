defmodule Ammo.PhotoInAlbum do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ammo.{Photo,Album,PhotoInAlbum}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @type t :: Ecto.Schema.t

  schema "photos_in_albums" do
    belongs_to :photo, Photo
    belongs_to :album, Album

    timestamps()
  end

  @doc false
  def changeset(%PhotoInAlbum{} = photo_in_album, attrs) do
    photo_in_album
    |> cast(attrs, ~w|photo_id album_id|a)
    |> validate_required(~w|photo_id album_id|a)
#     |> unique_constraint(:sha, name: :photos_sha_index)
  end
end
