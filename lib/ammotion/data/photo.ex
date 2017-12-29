defmodule Ammo.Photo do
  alias Ammo.{Photo,Album,PhotoInAlbum,User,Repo}

  @fields ~w|image sha latlon taken_at user_id|a

  use Ecto.Schema
  use Arc.Ecto.Schema
  @default :en
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "photos" do
    field :image, Ammo.PhotoUploader.Type
    field :caption, :map

    field :sha, :string
    field :taken_at, :naive_datetime
    field :latlon, Geo.Point

    belongs_to :user, User
    many_to_many :albums, Album, join_through: PhotoInAlbum

    timestamps()
  end

  use Ammo.Helpers.Ecto, fields: [:albums | @fields]

  @doc false
  def changeset(%Photo{} = photo, attrs \\ %{}) do
    photo
    |> Repo.preload(:albums)
    |> cast(attrs, @fields)
    |> cast_attachments(attrs, [:image])
    # |> validate_required(~w|user_id|a) # FIXME
    |> validate_path()
    |> revalidate_caption()
    |> revalidate_sha()
    |> revalidate_gps()
    |> put_assoc(:albums, attrs[:albums] || []) # FIXME
  end

  ##############################################################################

  def suck(path, user_id) do
    with {:ok, files} <- File.ls(path) do
      Enum.map(files,
        &Photo.new!(
          %{image: %Plug.Upload{filename: &1, path: Path.join(path, &1)}, user_id: user_id}))
    end
  end

  ##############################################################################
  defp path(%Ecto.Changeset{changes: %{image: %{file_name: path}}}), do: "uploads/" <> path
  defp path(_), do: nil

  defp path_error(%Ecto.Changeset{errors: errors, changes: photo} = changes, key, msg) do
    new_errors = [{:path, {msg, [validation: key]}}]
    %{changes | changes: photo, errors: new_errors ++ errors, valid?: false}
  end

  defp validate_path(%Ecto.Changeset{} = changes) do
    case path(changes) do
      nil ->
        path_error(changes, :no_image_path, "No path given.")
      path when is_binary(path) ->
        case {File.exists?(path), File.dir?(path)} do
          {true, false} ->
            changes
          {true, true} ->
            path_error(changes, :is_directory, "Directory given.")
          {false, _} ->
            path_error(changes, :inexisting_image_path, "Bad file path given.")
        end
      invalid ->
        path_error(changes, :invalid_image_path, "Unrecognizable path given: #{inspect(invalid)}.")
    end
  end

  defp revalidate_caption(%Ecto.Changeset{changes: %{caption: <<caption :: binary>>} = changes} = changeset),
    do: revalidate_caption(%Ecto.Changeset{changeset | changes: %{changes | caption: %{@default => caption}}})
  defp revalidate_caption(%Ecto.Changeset{changes: %{caption: %{@default => <<_ :: binary>>}}} = changeset),
    do: changeset
  defp revalidate_caption(%Ecto.Changeset{changes: %{} = changes} = changeset),
    do: revalidate_caption(%Ecto.Changeset{changeset | changes: Map.put(changes, :caption, "")})

  defp sha(path) when is_binary(path) do
    path
    |> File.stream!([], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
  end
  defp sha(_), do: nil

  defp revalidate_sha(%Ecto.Changeset{} = changes) do
    sha =
      changes
      |> path()
      |> sha()

    case sha do
      nil -> changes
      _ ->
        changes
        |> change(%{sha: sha})
        |> unique_constraint(:sha, name: :photos_sha_index) # FIXME
    end
  end

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

  defp gps(path) when is_binary(path) do
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
  defp gps(_), do: nil

  defp revalidate_gps(%Ecto.Changeset{} = changes) do
    gps =
      changes
      |> path()
      |> gps()

    case gps do
      %{} -> change(changes, gps)
      _ -> changes
    end
  end
end
