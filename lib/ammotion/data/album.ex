defmodule Ammo.Album do
  alias Ammo.{Photo,Album,PhotoInAlbum,User,Repo}

  @fields ~w|name user_id|a

  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "albums" do
    field :name, :string

    belongs_to :user, User
    many_to_many :photos, Photo, join_through: PhotoInAlbum

    timestamps()
  end

  use Ammo.Helpers.Ecto, fields: [:photos | @fields]

  @doc false
  def changeset(%Album{} = album, attrs) do
    album
    |> Repo.preload(:photos)
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> put_assoc(:photos, attrs[:photos] || []) # FIXME
  end

  ##############################################################################

  def as_json(id) do
    query =
      from a in Album,
      where: a.id == ^id,
      preload: [:photos]

    album = Repo.one(query)
  end
end
