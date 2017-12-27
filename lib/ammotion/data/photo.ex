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
    field :taken_at, :naive_datetime
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
    |> revalidate_gps()
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

  # defp revalidate_sha(%Ecto.Changeset{changes: %Photo{sha: sha}} = changes)
  #   when is_binary(sha), do: changes

  defp revalidate_sha(%Ecto.Changeset{changes: photo} = changes),
    do: change(changes, %{sha: sha(photo[:path])})

  defp latlon_ref_to_int(%Exexif.Data.Gps{gps_latitude_ref: "S", gps_longitude_ref: "W"}), do: [-1, -1]
  defp latlon_ref_to_int(%Exexif.Data.Gps{gps_latitude_ref: "S"}), do: [-1, 1]
  defp latlon_ref_to_int(%Exexif.Data.Gps{gps_longitude_ref: "W"}), do: [1, -1]
  defp latlon_ref_to_int(%Exexif.Data.Gps{}), do: [1, 1]

  defp lat_or_lon([g, m, s]), do: g + m / 60.0 + s / 3600.0
  defp lat_or_lon(_), do: nil
  defp latlon(%Exexif.Data.Gps{gps_latitude: [_, _, _] = lat, gps_longitude: [_, _, _] = lon} = gps) do
    [lat, lon]
    |> Enum.map(&lat_or_lon/1)
    |> Enum.zip(latlon_ref_to_int(gps))
    |> Enum.map(fn {ll, ref} -> ll * ref end)
    |> List.to_tuple()
  end
  defp latlon(_gps), do: nil

  defp ts(%Exexif.Data.Gps{gps_date_stamp: <<date :: binary>>, gps_time_stamp: [_, _, _] = time}) do
    date =
      date
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    [date, time]
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
    |> NaiveDateTime.from_erl!()
  end
  defp ts(_gps), do: nil

  defp gps(path) do
    with {:ok, info} <- Exexif.exif_from_jpeg_file(path) do
      case {ts(info.gps), latlon(info.gps)} do
        {nil, nil} ->
          %{}
        {nil, latlon} ->
          %{latlon: %Geo.Point{coordinates: latlon, srid: 4326}}
        {taken_at, nil} ->
          %{taken_at: taken_at}
        {taken_at, latlon} ->
          %{
            taken_at: taken_at,
            latlon: %Geo.Point{coordinates: latlon, srid: 4326} # FIXME WTF is srid ??
          }
      end
    else
      _ -> %{}
    end
  end

  # defp revalidate_gps(%Ecto.Changeset{changes: %Photo{taken_at: taken_at, latlon: latlon}} = changes)
  #   when not is_nil(latlon) and not is_nil(taken_at), do: changes

  defp revalidate_gps(%Ecto.Changeset{changes: photo} = changes) do
    change(changes, gps(photo[:path]))
  end
end