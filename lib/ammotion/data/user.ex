defmodule Ammo.User do
  import Ecto.Changeset
  alias Ammo.User

  @fields ~w|name email|a

  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  use Ammo.Helpers.Ecto, fields: @fields

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:email)
  end
end
