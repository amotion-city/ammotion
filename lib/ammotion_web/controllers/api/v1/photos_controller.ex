import AmmoWeb.Router.Helpers

defmodule AmmoWeb.Api.V1.PhotosController do
  use AmmoWeb, :controller

  require Logger

  alias AmmoWeb.Endpoint

  def index(conn, _params) do
    render conn, "index.html", current_user: get_session(conn, :current_user)
  end
end
