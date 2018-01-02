defmodule AmmoWeb.PhotoController do
  use AmmoWeb, :controller
  alias Ammo.{Photo,Repo}

  def index(conn, _) do
    user = get_session(conn, :current_user) # FIXME
    images = Repo.all(Photo)
    render(conn, "index.html", images: images, current_user: user)
  end

  def new(conn, _) do
    user = get_session(conn, :current_user) # FIXME
    changeset = Photo.changeset(%Photo{}, %{user_id: user.user.id})
    render(conn, "new.html", changeset: changeset, current_user: user)
  end

  def create(conn, %{"photo" => photo_params}) do
    IO.inspect photo_params, label: "[photo_controller.ex:17]"
    changeset = Photo.changeset(%Photo{}, photo_params)
    case Repo.insert(changeset) do
      {:ok, _photo} ->
        conn
        |> put_flash(:info, "Image was added")
        |> redirect(to: photo_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong: #{inspect(changeset)}")
        |> render("new.html", changeset: changeset)
    end
  end
end
