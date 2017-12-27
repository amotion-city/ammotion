defmodule Ammo.Album do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ammo.{Photo,Album,PhotoInAlbum}


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "albums" do
    field :name, :string

    belongs_to :user, User
    has_many :photos_in_albums, PhotoInAlbum
    has_many :albums, through: [:photos_in_albums, :Album]

    timestamps()
  end

  @doc false
  def changeset(%Album{} = album, attrs) do
    album
    |> cast(attrs, ~w|name user_id|a)
    |> validate_required(~w|name user_id|a)
  end
end
