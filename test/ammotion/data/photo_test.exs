defmodule Ammo.Photo.Test do
  use ExUnit.Case, async: true
  use Ammo.DataCase
  alias Ammo.{Repo,Photo,Album}

  doctest Ammo.Photo

  setup _context do
    Ecto.Adapters.SQL.Sandbox.mode(Ammo.Repo, {:shared, self()})
    [user: Ammo.User.new!(name: "Aleksei", email: "am@amotion.city")]
  end

  test "Photo.new!/1", %{user: user} do
    Photo.new!(path: "images/1.jpg", user_id: user.id)

    assert Enum.count(Repo.all(Photo)) == 1
  end

  test "Album.new!/1", %{user: user} do
    photos = Photo.suck("images", user.id)
    assert Enum.count(Repo.all(Photo)) == 7

    Album.new!(name: "My Album", user_id: user.id, photos: photos)
    [album] = Repo.all from a in Album, preload: [:photos]
    assert Repo.all(Photo) == album.photos
  end

  test "Album.as_json/1", %{user: user} do
    photos = Photo.suck("images", user.id)
    Album.new!(name: "My Album", user_id: user.id, photos: photos)
    [album] = Repo.all from a in Album, preload: [:photos]

    assert %{photos: photos} = Album.as_json(album.id)
    assert Enum.count(photos) == 7
    assert photos |> Enum.map(& &1.author) |> Enum.uniq == ["Aleksei"]
  end
end
