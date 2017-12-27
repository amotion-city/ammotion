defmodule Ammo.Photo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ammo.Photo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @type t :: Ecto.Schema.t
  @fields ~w|path sha latlon|a

  schema "photos" do
    field :path, :string
    field :sha, :string
    field :latlon, Geo.Point

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Photo{} = photo, attrs) do
    photo
    |> cast(attrs, ~w|path sha latlon|a)
    |> validate_required(~w|path|a)
    |> validate_path()
    |> revalidate_sha()
    |> revalidate_latlon()
    |> unique_constraint(:sha, name: :photos_sha_index)
  end

  @doc "Returns a changeset"
  def new?(attrs) when is_list(attrs) do
    attrs
    |> Keyword.take(@fields)
    |> Enum.into(%{})
    |> new?()
  end
  def new?(attrs) when is_map(attrs),
    do: Photo.changeset(%__MODULE__{}, attrs)

  @doc "Returns an in-memory object"
  def new(attrs), do: attrs |> new?() |> apply_changes()
  @doc "Persists an object"
  def new!(attrs) do
    case attrs |> new?() |> Ammo.Repo.insert() do
      {:ok, %Photo{} = photo} ->
        photo
      {:error, %{errors: errors}} ->
        {:error, errors |> Enum.map(fn {k, {msg, _}} -> "#{k}: #{msg}" end)}
    end
  end

  ##############################################################################

  def suck(path) do
    with {:ok, files} <- File.ls(path) do
      Enum.map(files, &Photo.new!(%{path: &1}))
    end
  end

  ##############################################################################

  defp validate_path(%Ecto.Changeset{errors: errors, changes: photo} = changes) do
    case {File.exists?(photo[:path]), File.dir?(photo[:path])} do
      {true, false} ->
        changes
      {true, false} ->
        new_errors = [{:path, {"Directory given.", [validation: :is_directory]}}]
        %{changes | changes: photo, errors: new_errors ++ errors, valid?: false}
      _ ->
        new_errors = [{:path, {"Bad file path given.", [validation: :invalid_path]}}]
        %{changes | changes: photo, errors: new_errors ++ errors, valid?: false}
    end
  end

  defp sha(path) do
    path
    |> File.stream!([], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
  end

  # defp revalidate_sha(%Ecto.Changeset{errors: errors, changes: %Photo{sha: sha}} = changes)
  #   when is_binary(sha), do: changes

  defp revalidate_sha(%Ecto.Changeset{errors: errors, changes: photo} = changes),
    do: change(changes, %{sha: sha(photo[:path])})

  defp latlon(path) do
    with {:ok, info} <- Exexif.exif_from_jpeg_file(path),
         {lat, lon} when not is_nil(lat) and not is_nil(lon) <- {info.gps.gps_latitude, info.gps.gps_longitude} do
      %Geo.Point{coordinates: {lat, lon}} # , srid: 4326} FIXME ??
    else
      _ -> nil
    end
  end

  # defp revalidate_latlon(%Ecto.Changeset{errors: errors, changes: %Photo{latlon: latlon}} = changes)
  #   when not is_nil(latlon), do: changes

  defp revalidate_latlon(%Ecto.Changeset{errors: errors, changes: photo} = changes),
    do: change(changes, %{latlon: latlon(photo[:path])})
end
