defmodule Ammo.UserAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ammo.UserAccount


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_accounts" do
    field :type, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserAccount{} = user_account, attrs) do
    user_account
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
