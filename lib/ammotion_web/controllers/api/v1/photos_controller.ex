import AmmoWeb.Router.Helpers

defmodule AmmoWeb.Api.V1.PhotosController do
  use AmmoWeb, :controller
  import Ecto.Query

  require Logger

  alias Ammo.{Photo,Repo}
  alias AmmoWeb.Endpoint

  def index(conn, _params) do
    # json conn, %{current_user: get_session(conn, :current_user).user}
    json conn, %{photos: Repo.all(from p in Photo, select: p.id)}
  end
end
