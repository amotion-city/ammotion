import AmmoWeb.Router.Helpers

defmodule AmmoWeb.Api.V1.AlbumsController do
  use AmmoWeb, :controller
  import Ecto.Query

  require Logger

  # alias AmmoWeb.Endpoint
  alias Ammo.{Repo,Album}

  def index(conn, _params) do
    # IO.inspect album_path(conn, :index)
    urls =
      (from a in Album, select: a.id)
      |> Repo.all()
      |> Enum.map(& Enum.join([AmmoWeb.Endpoint.url, api_v1_albums_path(conn, :index), &1], "/"))
    json conn, %{albums: urls}
  end

  def show(conn, %{"id" => id} = _params) do
    json conn, %{album: Album.as_json(id)}
  end
end
