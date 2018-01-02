defmodule Ammo.UserAccount do
  use Ecto.Schema

  import Ecto.{Changeset,Query}

  alias Ammo.{Repo,User,UserAccount}
  alias Ueberauth.Auth

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_accounts" do
    field :type, :string
    field :raw_info, :map

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserAccount{} = user_account, attrs \\ %{}) do
    user_account
    |> cast(attrs, [:type, :raw_info])
    |> validate_required([:type, :raw_info])
  end

  def lookup(%Auth{info: %Auth.Info{email: email} = info, provider: type} = _auth) do
    user =
      Repo.one(from u in User, where: u.email == ^email) ||
      User.new!(%{name: "[Anonymous]", email: email})

    account =
      Repo.one(from ua in UserAccount, where: ua.user_id == ^user.id) ||
      (%UserAccount{}
        |> changeset(%{type: to_string(type), raw_info: Map.from_struct(info)})
        |> Repo.insert!())

    %{user: user, account: account}
  end
end
