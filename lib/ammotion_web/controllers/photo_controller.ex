defmodule AmmoWeb.PhotoController do
  use AmmoWeb, :controller
  alias Ammo.{Photo,Repo}

  def index(conn, _) do
    images = Repo.all(Photo)
    render(conn, "index.html", images: images)
  end

  def new(conn, _) do
    # user = get_session(conn, :current_user) # FIXME
    changeset = Photo.changeset(%Photo{}, %{user_id: "3c07ecac-ce73-4f41-a948-108604125f10"})
    render(conn, "new.html", changeset: changeset)
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
