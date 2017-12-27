import AmmoWeb.Router.Helpers

defmodule AmmoWeb.Api.V1.AlbumsController do
  use AmmoWeb, :controller
  import Ecto.Query

  require Logger

  # alias AmmoWeb.Endpoint
  alias Ammo.{Repo,Photo,Album}

  def index(conn, _params) do
    json conn, %{albums: Repo.all(from a in Album, select: a.id)}
  end

  def show(conn, %{"id" => id} = _params) do
    json conn, %{album: Album.as_json(id)}
  end
end
