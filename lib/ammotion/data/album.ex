defmodule Ammo.Album do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ammo.Album


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "albums" do
    field :name, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Album{} = album, attrs) do
    album
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
