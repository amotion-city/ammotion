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
  def changeset(%Album{} = album, attrs \\ %{}) do
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
      preload: [:user, photos: :user]

    with album <- Repo.one(query) do
      %{
        name: album.name,
        owner: album.user.name,
        photos:
          Enum.map(album.photos, fn photo ->
            {lat, lon} =
              case photo.latlon do
                nil -> {nil, nil}
                latlon -> latlon.coordinates
              end
            %{
              coords: %{lat: lat, lon: lon},
              taken_at: photo.taken_at,
              author: photo.user.name
            }
          end)
      }
    end
  end
end
