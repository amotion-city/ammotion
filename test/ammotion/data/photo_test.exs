defmodule Ammo.Photo.Test do
  use ExUnit.Case, async: true
  doctest Ammo.Photo

  use Ammo.DataCase

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ammo.Repo, {:shared, self()})
  end

  test "new!/1" do
    IO.inspect File.cwd, label: "★"
    photo = Ammo.Photo.new!(path: "images/1.jpg")

    assert Enum.count(Ammo.Photo.all()) == 1
  end
end
